#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
NVIM="${NVIM_BIN:-$(command -v nvim || true)}"
TEMP_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf -- "${TEMP_ROOT}"
}
trap cleanup EXIT

[[ -n "${NVIM}" ]] || { printf 'ERROR: nvim is not available.\n' >&2; exit 1; }

mkdir -p -- \
  "${TEMP_ROOT}/config" \
  "${TEMP_ROOT}/data" \
  "${TEMP_ROOT}/state" \
  "${TEMP_ROOT}/cache"
ln -s -- "${REPO_ROOT}" "${TEMP_ROOT}/config/nvim"

run_nvim() {
  env \
    XDG_CONFIG_HOME="${TEMP_ROOT}/config" \
    XDG_DATA_HOME="${TEMP_ROOT}/data" \
    XDG_STATE_HOME="${TEMP_ROOT}/state" \
    XDG_CACHE_HOME="${TEMP_ROOT}/cache" \
    "${NVIM}" --headless \
    "+lua assert(package.loaded['config.options'], 'config.options not loaded')" \
    "+lua assert(package.loaded['config.keymaps'], 'config.keymaps not loaded')" \
    "+lua assert(package.loaded['config.autocmds'], 'config.autocmds not loaded')" \
    "+lua assert(package.loaded['config.lazy'], 'config.lazy not loaded')" \
    "+lua assert(package.loaded.lazy, 'lazy.nvim not loaded')" \
    +qa
}

printf 'Smoke test: first isolated startup and lazy.nvim bootstrap.\n'
run_nvim
printf 'Smoke test: second isolated startup.\n'
run_nvim
printf 'Smoke test passed.\n'
