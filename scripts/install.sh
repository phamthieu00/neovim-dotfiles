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
  command -v gzip >/dev/null 2>&1 || packages+=(gzip)
  command -v unzip >/dev/null 2>&1 || packages+=(unzip)
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
  for command_name in git curl tar gzip unzip sha256sum; do
    command -v "${command_name}" >/dev/null 2>&1 || missing+=("${command_name}")
  done

  if ((${#missing[@]} > 0)); then
    die "automatic provisioning is currently supported only on Ubuntu; install: ${missing[*]}"
  fi
}

version_at_least() {
  local current=$1 minimum=$2
  [[ "$(printf '%s\n%s\n' "${minimum}" "${current}" | sort -V | head -n 1)" == "${minimum}" ]]
}

ensure_coding_tools() {
  local -a missing=()
  local node_version tree_sitter_version

  command -v rg >/dev/null 2>&1 || missing+=("ripgrep (rg)")
  command -v make >/dev/null 2>&1 || missing+=(make)
  if ! command -v cc >/dev/null 2>&1 \
    && ! command -v gcc >/dev/null 2>&1 \
    && ! command -v clang >/dev/null 2>&1; then
    missing+=("a C compiler")
  fi

  if command -v node >/dev/null 2>&1; then
    node_version="$(node --version | sed 's/^v//')"
    version_at_least "${node_version}" "22.22.2" || missing+=("Node.js >= 22.22.2")
  else
    missing+=("Node.js >= 22.22.2")
  fi
  command -v npm >/dev/null 2>&1 || missing+=(npm)

  if command -v tree-sitter >/dev/null 2>&1; then
    tree_sitter_version="$(tree-sitter --version | awk '{ print $2 }')"
    version_at_least "${tree_sitter_version}" "0.26.1" || missing+=("tree-sitter CLI >= 0.26.1")
  else
    missing+=("tree-sitter CLI >= 0.26.1")
  fi

  if ((${#missing[@]} > 0)); then
    printf 'ERROR: missing Coding MVP prerequisites:\n' >&2
    printf '  - %s\n' "${missing[@]}" >&2
    if [[ "$(uname -s)" == Linux && -r /etc/os-release ]]; then
      # shellcheck disable=SC1091
      source /etc/os-release
      if [[ "${ID:-}" == ubuntu ]]; then
        printf 'Ubuntu guidance:\n' >&2
        printf '  sudo apt-get update && sudo apt-get install -y build-essential ripgrep\n' >&2
        printf '  Install Node.js >= 22.22.2 (with npm) from https://nodejs.org/ or your version manager.\n' >&2
        printf '  Install tree-sitter CLI >= 0.26.1 from https://github.com/tree-sitter/tree-sitter/releases.\n' >&2
      fi
    fi
    printf 'See docs/installation.md for supported versions and verification commands.\n' >&2
    exit 1
  fi

  if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
    log "WARNING: fd is unavailable; Telescope file search will use ripgrep."
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
ensure_coding_tools
link_configuration

log "Synchronizing plugins and parser revisions."
"${ACTIVE_NVIM}" --headless '+Lazy! sync' +qa

log "Installing Mason-managed language servers and formatters."
"${ACTIVE_NVIM}" --headless \
  '+Lazy! load mason.nvim' \
  '+MasonInstall lua-language-server typescript-language-server stylua prettierd' \
  +qa

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
