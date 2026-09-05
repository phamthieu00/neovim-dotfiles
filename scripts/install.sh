#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
CONFIG_ROOT="${XDG_CONFIG_HOME:-${HOME}/.config}"
CONFIG_LINK="${CONFIG_ROOT}/nvim"
LOCAL_BIN="${HOME}/.local/bin"
LOCAL_OPT="${HOME}/.local/opt"
NVIM_VERSION="0.12.3"

ACTIVE_NVIM=""
BACKUP_PATH=""
CONFIG_CHANGED=false
TEMP_DIR=""

log() {
  printf '%s\n' "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  local status=$?

  if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
    rm -rf -- "${TEMP_DIR}"
  fi

  if ((status != 0)) && [[ "${CONFIG_CHANGED}" == true ]]; then
    printf 'Installation failed; restoring the previous Neovim configuration.\n' >&2
    if [[ -L "${CONFIG_LINK}" ]] && [[ "$(readlink -f -- "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then
      rm -- "${CONFIG_LINK}"
    fi
    if [[ -n "${BACKUP_PATH}" ]] && [[ -e "${BACKUP_PATH}" || -L "${BACKUP_PATH}" ]]; then
      mv -- "${BACKUP_PATH}" "${CONFIG_LINK}"
    fi
  fi

  exit "${status}"
}
trap cleanup EXIT

has_compatible_nvim() {
  local candidate=$1
  "${candidate}" --headless -u NONE \
    '+if has("nvim-0.12") == 0 | cquit 1 | endif' +qa >/dev/null 2>&1
}

install_ubuntu_prerequisites() {
  local -a packages=()
  local -a apt_command=(apt-get)

  command -v git >/dev/null 2>&1 || packages+=(git)
  command -v curl >/dev/null 2>&1 || packages+=(curl)
  command -v tar >/dev/null 2>&1 || packages+=(tar)
  command -v sha256sum >/dev/null 2>&1 || packages+=(coreutils)
  [[ -f /etc/ssl/certs/ca-certificates.crt ]] || packages+=(ca-certificates)

  ((${#packages[@]} == 0)) && return

  if ((EUID != 0)); then
    command -v sudo >/dev/null 2>&1 || die "sudo is required to install: ${packages[*]}"
    apt_command=(sudo apt-get)
  fi

  log "Installing core prerequisites: ${packages[*]}"
  "${apt_command[@]}" update
  "${apt_command[@]}" install -y "${packages[@]}"
}

ensure_core_tools() {
  local system
  system="$(uname -s)"

  if [[ "${system}" == Linux && -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ "${ID:-}" == ubuntu ]]; then
      install_ubuntu_prerequisites
    fi
  fi

  local missing=()
  local command_name
  for command_name in git curl tar sha256sum; do
    command -v "${command_name}" >/dev/null 2>&1 || missing+=("${command_name}")
  done

  if ((${#missing[@]} > 0)); then
    die "automatic provisioning is currently supported only on Ubuntu; install: ${missing[*]}"
  fi
}

install_neovim() {
  local machine asset checksum archive extracted destination
  machine="$(uname -m)"

  case "${machine}" in
    x86_64)
      asset="nvim-linux-x86_64.tar.gz"
      checksum="c441b547142860bf01bcce39e36cbed185c41112813e15443b16e5237750724d"
      ;;
    aarch64 | arm64)
      asset="nvim-linux-arm64.tar.gz"
      checksum="e055af73fa9c72b37456da8d204fa5c09850bc07e80e9176fe3b87d4afb7a3fc"
      ;;
    *)
      die "no Neovim ${NVIM_VERSION} archive is configured for architecture ${machine}"
      ;;
  esac

  destination="${LOCAL_OPT}/nvim-v${NVIM_VERSION}"
  if [[ -x "${destination}/bin/nvim" ]] && has_compatible_nvim "${destination}/bin/nvim"; then
    ACTIVE_NVIM="${destination}/bin/nvim"
  else
    [[ ! -e "${destination}" ]] || die "refusing to replace unexpected path ${destination}"

    TEMP_DIR="$(mktemp -d)"
    archive="${TEMP_DIR}/${asset}"
    log "Downloading Neovim ${NVIM_VERSION} for ${machine}."
    curl --fail --location --retry 3 \
      --output "${archive}" \
      "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${asset}"
    printf '%s  %s\n' "${checksum}" "${archive}" | sha256sum --check --status \
      || die "Neovim archive checksum verification failed"

    tar -xzf "${archive}" -C "${TEMP_DIR}"
    extracted="${TEMP_DIR}/${asset%.tar.gz}"
    [[ -x "${extracted}/bin/nvim" ]] || die "downloaded Neovim archive has an unexpected layout"

    mkdir -p -- "${LOCAL_OPT}"
    mv -- "${extracted}" "${destination}"
    ACTIVE_NVIM="${destination}/bin/nvim"
  fi

  mkdir -p -- "${LOCAL_BIN}"
  if [[ ! -e "${LOCAL_BIN}/nvim" && ! -L "${LOCAL_BIN}/nvim" ]]; then
    ln -s -- "${ACTIVE_NVIM}" "${LOCAL_BIN}/nvim"
  elif [[ "$(readlink -f -- "${LOCAL_BIN}/nvim")" != "${ACTIVE_NVIM}" ]]; then
    die "refusing to replace unrelated ${LOCAL_BIN}/nvim"
  fi
}

select_neovim() {
  local current_nvim
  current_nvim="$(command -v nvim || true)"

  if [[ -n "${current_nvim}" ]] && has_compatible_nvim "${current_nvim}"; then
    ACTIVE_NVIM="${current_nvim}"
    return
  fi

  [[ "$(uname -s)" == Linux ]] \
    || die "Neovim 0.12+ is required; automatic Neovim installation currently supports Linux only"
  install_neovim
}

next_backup_path() {
  local base candidate counter=0
  base="${CONFIG_LINK}.backup.$(date +%Y%m%d-%H%M%S)"
  candidate="${base}"
  while [[ -e "${candidate}" || -L "${candidate}" ]]; do
    ((counter += 1))
    candidate="${base}.${counter}"
  done
  printf '%s\n' "${candidate}"
}

link_configuration() {
  mkdir -p -- "${CONFIG_ROOT}"

  if [[ -L "${CONFIG_LINK}" ]] && [[ "$(readlink -f -- "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then
    log "Neovim configuration already points to ${REPO_ROOT}."
    return
  fi

  if [[ -e "${CONFIG_LINK}" || -L "${CONFIG_LINK}" ]]; then
    BACKUP_PATH="$(next_backup_path)"
    mv -- "${CONFIG_LINK}" "${BACKUP_PATH}"
    log "Backed up the existing configuration to ${BACKUP_PATH}."
  fi

  CONFIG_CHANGED=true
  ln -s -- "${REPO_ROOT}" "${CONFIG_LINK}"
}

ensure_core_tools
select_neovim
link_configuration

log "Bootstrapping Neovim and lazy.nvim."
"${ACTIVE_NVIM}" --headless +qa

NVIM_BIN="${ACTIVE_NVIM}" "${SCRIPT_DIR}/doctor.sh"
NVIM_BIN="${ACTIVE_NVIM}" "${REPO_ROOT}/tests/smoke-test.sh"

CONFIG_CHANGED=false

log "Installation complete."
log "Configuration: ${CONFIG_LINK} -> ${REPO_ROOT}"
[[ -z "${BACKUP_PATH}" ]] || log "Backup: ${BACKUP_PATH}"
if [[ ":${PATH}:" != *":${LOCAL_BIN}:"* ]]; then
  log "Add ${LOCAL_BIN} to PATH before starting a new shell."
fi
log "Next: run 'make doctor', then start Neovim."
