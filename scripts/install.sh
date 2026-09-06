#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
SYSTEM="$(uname -s)"
MACHINE="$(uname -m)"
NVIM_VERSION="0.12.3"
LOCAL_BIN="${HOME}/.local/bin"
LOCAL_OPT="${HOME}/.local/opt"
ACTIVE_NVIM=""
NVIM_INSTALLED_BY_REPO=false
BACKUP_PATH=""
CONFIG_CHANGED=false
TEMP_DIR=""

if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
  CONFIG_ROOT="${XDG_CONFIG_HOME}"
else
  CONFIG_ROOT="${HOME}/.config"
fi
if [[ -n "${XDG_DATA_HOME:-}" ]]; then
  DATA_ROOT="${XDG_DATA_HOME}/nvim"
else
  DATA_ROOT="${HOME}/.local/share/nvim"
fi
if [[ -n "${XDG_STATE_HOME:-}" ]]; then
  STATE_ROOT="${XDG_STATE_HOME}/nvim"
else
  STATE_ROOT="${HOME}/.local/state/nvim"
fi
if [[ -n "${XDG_CACHE_HOME:-}" ]]; then
  CACHE_ROOT="${XDG_CACHE_HOME}/nvim"
else
  CACHE_ROOT="${HOME}/.cache/nvim"
fi
CONFIG_LINK="${CONFIG_ROOT}/nvim"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

resolve_path() {
  local path="$1" target
  if [[ -L "${path}" ]]; then
    target="$(readlink "${path}")"
    [[ "${target}" = /* ]] || target="$(dirname "${path}")/${target}"
    resolve_path "${target}"
  else
    (cd -P "$(dirname "${path}")" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$(basename "${path}")")
  fi
}

sha256_check() {
  local expected="$1" archive="$2" sha256_help actual
  if command -v sha256sum >/dev/null 2>&1; then
    # macOS also ships a sha256sum binary, but its BSD interface does not
    # implement GNU's --check/--status options.
    sha256_help="$(sha256sum --help 2>&1 || true)"
    if [[ "${sha256_help}" == *'--check'* ]]; then
      printf '%s  %s\n' "${expected}" "${archive}" | sha256sum --check --status
      return
    fi
  fi
  if command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "${archive}" | awk '{print $1}')"
    [[ "${actual}" == "${expected}" ]]
    return
  fi
  return 1
}

cleanup() {
  local status=$?
  [[ -z "${TEMP_DIR}" || ! -d "${TEMP_DIR}" ]] || rm -rf "${TEMP_DIR}"
  if ((status != 0)) && [[ "${CONFIG_CHANGED}" == true ]]; then
    printf 'Installation failed; restoring the previous Neovim configuration.\n' >&2
    if [[ -L "${CONFIG_LINK}" ]] && [[ "$(resolve_path "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then rm -f "${CONFIG_LINK}"; fi
    if [[ -n "${BACKUP_PATH}" ]] && [[ -e "${BACKUP_PATH}" || -L "${BACKUP_PATH}" ]]; then mv "${BACKUP_PATH}" "${CONFIG_LINK}"; fi
  fi
  exit "${status}"
}
trap cleanup EXIT

has_compatible_nvim() { local candidate="$1"; "${candidate}" --headless -u NONE '+if has("nvim-0.12") == 0 | cquit 1 | endif' +qa >/dev/null 2>&1; }

install_ubuntu_prerequisites() {
  local -a packages=() apt_command=(apt-get) command_name
  command -v git >/dev/null 2>&1 || packages+=(git); command -v curl >/dev/null 2>&1 || packages+=(curl); command -v tar >/dev/null 2>&1 || packages+=(tar); command -v gzip >/dev/null 2>&1 || packages+=(gzip); command -v unzip >/dev/null 2>&1 || packages+=(unzip); command -v sha256sum >/dev/null 2>&1 || packages+=(coreutils); [[ -f /etc/ssl/certs/ca-certificates.crt ]] || packages+=(ca-certificates)
  ((${#packages[@]} == 0)) && return
  if ((EUID != 0)); then command -v sudo >/dev/null 2>&1 || die "sudo is required to install: ${packages[*]}"; apt_command=(sudo apt-get); fi
  log "Installing transport prerequisites: ${packages[*]}"; "${apt_command[@]}" update; "${apt_command[@]}" install -y "${packages[@]}"
}

install_macos_prerequisites() {
  if ! command -v brew >/dev/null 2>&1; then
    [[ "${NEOVIM_NO_BREW_BOOTSTRAP:-0}" != 1 ]] || die 'Homebrew is required; unset NEOVIM_NO_BREW_BOOTSTRAP to allow automatic installation'
    TEMP_DIR="$(mktemp -d)"; log 'Homebrew was not found; installing it with the official non-interactive installer.'
    curl --fail --location --retry 3 --output "${TEMP_DIR}/brew-install.sh" https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    NONINTERACTIVE=1 /bin/bash "${TEMP_DIR}/brew-install.sh"; TEMP_DIR=""
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; elif [[ -x /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv)"; fi
  local -a packages=()
  command -v git >/dev/null 2>&1 || packages+=(git); command -v rg >/dev/null 2>&1 || packages+=(ripgrep); command -v fd >/dev/null 2>&1 || packages+=(fd); command -v node >/dev/null 2>&1 || packages+=(node); command -v tree-sitter >/dev/null 2>&1 || packages+=(tree-sitter-cli)
  ((${#packages[@]} == 0)) || brew install "${packages[@]}"
  command -v cc >/dev/null 2>&1 || die 'A C compiler is required. Install Xcode Command Line Tools with: xcode-select --install'
}

ensure_core_tools() {
  if [[ "${SYSTEM}" == Linux && -r /etc/os-release ]]; then # shellcheck disable=SC1091
    source /etc/os-release; [[ "${ID:-}" == ubuntu ]] && install_ubuntu_prerequisites
  elif [[ "${SYSTEM}" == Darwin ]]; then install_macos_prerequisites; fi
  local -a missing=() command_name
  for command_name in git curl tar gzip unzip; do command -v "${command_name}" >/dev/null 2>&1 || missing+=("${command_name}"); done
  command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1 || missing+=("sha256 checksum utility")
  ((${#missing[@]} == 0)) || die "Missing transport tools: ${missing[*]}. Install them with your OS package manager."
}

version_at_least() { awk -v a="${1#v}" -v b="${2#v}" 'BEGIN { na=split(a,A,"."); nb=split(b,B,"."); n=(na>nb?na:nb); for(i=1;i<=n;i++){ x=(A[i]+0); y=(B[i]+0); if(x>y) exit 0; if(x<y) exit 1 } exit 0 }'; }

ensure_coding_tools() {
  local -a missing=() node_version tree_sitter_version
  command -v rg >/dev/null 2>&1 || missing+=("ripgrep (rg)"); command -v make >/dev/null 2>&1 || missing+=(make)
  if ! command -v cc >/dev/null 2>&1 && ! command -v gcc >/dev/null 2>&1 && ! command -v clang >/dev/null 2>&1; then missing+=("a C compiler"); fi
  if command -v node >/dev/null 2>&1; then node_version="$(node --version | sed 's/^v//')"; version_at_least "${node_version}" 22.22.2 || missing+=("Node.js >= 22.22.2"); else missing+=("Node.js >= 22.22.2"); fi
  command -v npm >/dev/null 2>&1 || missing+=(npm)
  if command -v tree-sitter >/dev/null 2>&1; then tree_sitter_version="$(tree-sitter --version | awk '{print $2}')"; version_at_least "${tree_sitter_version}" 0.26.1 || missing+=("tree-sitter CLI >= 0.26.1"); else missing+=("tree-sitter CLI >= 0.26.1"); fi
  if ((${#missing[@]} > 0)); then printf 'ERROR: missing Coding MVP prerequisites:\n' >&2; printf '  - %s\n' "${missing[@]}" >&2; if [[ "${SYSTEM}" == Darwin ]]; then printf 'Install on macOS with: brew install ripgrep fd node tree-sitter-cli\nInstall Xcode Command Line Tools with: xcode-select --install\n' >&2; elif [[ "${SYSTEM}" == Linux ]]; then printf 'Ubuntu guidance: sudo apt-get update && sudo apt-get install -y build-essential ripgrep\n' >&2; fi; printf 'See docs/installation.md for supported versions.\n' >&2; exit 1; fi
  command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1 || log 'WARNING: fd is unavailable; Telescope will use ripgrep.'
}

install_neovim() {
  local asset checksum archive extracted destination
  case "${SYSTEM}:${MACHINE}" in
    Linux:x86_64) asset=nvim-linux-x86_64.tar.gz; checksum=c441b547142860bf01bcce39e36cbed185c41112813e15443b16e5237750724d;;
    Linux:aarch64|Linux:arm64) asset=nvim-linux-arm64.tar.gz; checksum=e055af73fa9c72b37456da8d204fa5c09850bc07e80e9176fe3b87d4afb7a3fc;;
    Darwin:arm64) asset=nvim-macos-arm64.tar.gz; checksum=532da1d00e465a660fa01c3d4991333d09c52107dce7df937368545daca0a14e;;
    Darwin:x86_64) asset=nvim-macos-x86_64.tar.gz; checksum=4b40e318eb7073321fa5fc06d7f60c3c0de1d7ea50ffbaa8b04286f5484d294f;;
    *) die "no Neovim ${NVIM_VERSION} archive is configured for ${SYSTEM}/${MACHINE}";;
  esac
  destination="${LOCAL_OPT}/nvim-v${NVIM_VERSION}"
  if [[ -x "${destination}/bin/nvim" ]] && has_compatible_nvim "${destination}/bin/nvim"; then ACTIVE_NVIM="${destination}/bin/nvim"; else
    [[ ! -e "${destination}" ]] || die "refusing to replace unexpected path ${destination}"
    TEMP_DIR="$(mktemp -d)"; archive="${TEMP_DIR}/${asset}"; log "Downloading Neovim ${NVIM_VERSION} for ${SYSTEM}/${MACHINE}."
    curl --fail --location --retry 3 --output "${archive}" "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${asset}"; sha256_check "${checksum}" "${archive}" || die 'Neovim archive checksum verification failed'
    tar -xzf "${archive}" -C "${TEMP_DIR}"; extracted="${TEMP_DIR}/${asset%.tar.gz}"; [[ -x "${extracted}/bin/nvim" ]] || die 'downloaded Neovim archive has an unexpected layout'
    mkdir -p "${LOCAL_OPT}"; mv "${extracted}" "${destination}"; ACTIVE_NVIM="${destination}/bin/nvim"; NVIM_INSTALLED_BY_REPO=true; [[ "${SYSTEM}" != Darwin ]] || xattr -c "${ACTIVE_NVIM}" "${ACTIVE_NVIM%/bin/nvim}" 2>/dev/null || true
  fi
  mkdir -p "${LOCAL_BIN}"; if [[ ! -e "${LOCAL_BIN}/nvim" && ! -L "${LOCAL_BIN}/nvim" ]]; then ln -s "${ACTIVE_NVIM}" "${LOCAL_BIN}/nvim"; elif [[ "$(resolve_path "${LOCAL_BIN}/nvim")" != "${ACTIVE_NVIM}" ]]; then die "refusing to replace unrelated ${LOCAL_BIN}/nvim"; fi
}

select_neovim() { local current_nvim="$(command -v nvim || true)"; if [[ -n "${current_nvim}" ]] && has_compatible_nvim "${current_nvim}"; then ACTIVE_NVIM="${current_nvim}"; else install_neovim; fi; }
next_backup_path() { local base="${CONFIG_LINK}.backup.$(date +%Y%m%d-%H%M%S)" candidate="${base}" counter=0; while [[ -e "${candidate}" || -L "${candidate}" ]]; do counter=$((counter + 1)); candidate="${base}.${counter}"; done; printf '%s\n' "${candidate}"; }
link_configuration() { mkdir -p "${CONFIG_ROOT}"; if [[ -L "${CONFIG_LINK}" ]] && [[ "$(resolve_path "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then log "Neovim configuration already points to ${REPO_ROOT}."; return; fi; if [[ -e "${CONFIG_LINK}" || -L "${CONFIG_LINK}" ]]; then BACKUP_PATH="$(next_backup_path)"; mv "${CONFIG_LINK}" "${BACKUP_PATH}"; log "Backed up the existing configuration to ${BACKUP_PATH}."; fi; CONFIG_CHANGED=true; ln -s "${REPO_ROOT}" "${CONFIG_LINK}"; }
record_ownership() { mkdir -p "${DATA_ROOT}" "${STATE_ROOT}" "${CACHE_ROOT}"; printf 'repository=%s\ndata_root=%s\nstate_root=%s\ncache_root=%s\nnvim_prefix=%s\nnvim_link=%s\nnvim_installed=%s\n' "${REPO_ROOT}" "${DATA_ROOT}" "${STATE_ROOT}" "${CACHE_ROOT}" "${ACTIVE_NVIM%/bin/nvim}" "${LOCAL_BIN}/nvim" "${NVIM_INSTALLED_BY_REPO}" > "${DATA_ROOT}/.neovim-config-owned"; }

ensure_core_tools; select_neovim; ensure_coding_tools; link_configuration
log 'Synchronizing plugins and parser revisions.'; "${ACTIVE_NVIM}" --headless '+Lazy! sync' '+lua assert(vim.fn.exists(":Lazy") == 2, "Lazy command is unavailable")' +qa
log 'Installing Mason-managed language servers and formatters.'; "${ACTIVE_NVIM}" --headless '+Lazy! load mason.nvim' '+MasonInstall lua-language-server typescript-language-server eslint-lsp json-lsp stylua prettierd' '+lua local r=require("mason-registry"); local p={"lua-language-server","typescript-language-server","eslint-lsp","json-lsp","stylua","prettierd"}; assert(vim.wait(120000, function() for _,n in ipairs(p) do if not r.is_installed(n) then return false end end return true end, 100), "timed out waiting for Mason packages"); for _,n in ipairs(p) do assert(r.is_installed(n), n .. " failed to install") end' +qa
NVIM_BIN="${ACTIVE_NVIM}" "${SCRIPT_DIR}/doctor.sh"; NVIM_BIN="${ACTIVE_NVIM}" "${REPO_ROOT}/tests/smoke-test.sh"
record_ownership
CONFIG_CHANGED=false; log 'Installation complete.'; log "Configuration: ${CONFIG_LINK} -> ${REPO_ROOT}"; [[ -z "${BACKUP_PATH}" ]] || log "Backup: ${BACKUP_PATH}"; [[ ":${PATH}:" == *":${LOCAL_BIN}:"* ]] || log "Add ${LOCAL_BIN} to PATH before starting a new shell."; log "Next: run 'make doctor', then start Neovim."
