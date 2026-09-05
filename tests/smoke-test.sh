#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
NVIM="${NVIM_BIN:-$(command -v nvim || true)}"
DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
NVIM_DATA="${DATA_HOME}/nvim"
TEMP_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf -- "${TEMP_ROOT}"
}
trap cleanup EXIT

[[ -n "${NVIM}" ]] || { printf 'ERROR: nvim is not available.\n' >&2; exit 1; }

required_plugins=(
  lazy.nvim
  telescope.nvim
  plenary.nvim
  telescope-fzf-native.nvim
  nvim-treesitter
  nvim-lspconfig
  mason.nvim
  mason-lspconfig.nvim
  blink.cmp
  conform.nvim
  gitsigns.nvim
)

for plugin in "${required_plugins[@]}"; do
  if [[ ! -d "${NVIM_DATA}/lazy/${plugin}" ]]; then
    printf 'ERROR: required plugin data is missing: %s\n' "${NVIM_DATA}/lazy/${plugin}" >&2
    printf 'Run make install (or :Lazy sync) before make test.\n' >&2
    exit 1
  fi
done

mkdir -p -- "${TEMP_ROOT}/config" "${TEMP_ROOT}/state" "${TEMP_ROOT}/cache"
ln -s -- "${REPO_ROOT}" "${TEMP_ROOT}/config/nvim"

run_nvim() {
  env \
    XDG_CONFIG_HOME="${TEMP_ROOT}/config" \
    XDG_DATA_HOME="${DATA_HOME}" \
    XDG_STATE_HOME="${TEMP_ROOT}/state" \
    XDG_CACHE_HOME="${TEMP_ROOT}/cache" \
    "${NVIM}" --headless "$@" \
    '+lua if vim.v.errmsg ~= "" then vim.cmd("cquit 1") end' +qa
}

check_runtime() {
  run_nvim \
    "+lua dofile([[${REPO_ROOT}/tests/smoke.lua]]).runtime()"
}

printf 'Smoke test: first network-free startup.\n'
check_runtime
printf 'Smoke test: second network-free startup.\n'
check_runtime

run_nvim "${REPO_ROOT}/tests/fixtures/test.lua" \
  "+lua assert(vim.bo.filetype == 'lua', 'Lua filetype detection failed'); assert(vim.wait(10000, function() return #vim.lsp.get_clients({ bufnr = 0, name = 'lua_ls' }) > 0 end), 'lua_ls did not attach')"
typescript_fixture="${REPO_ROOT}/tests/fixtures/typescript"
run_nvim "${typescript_fixture}/src/app.controller.ts" \
  "+lua dofile([[${REPO_ROOT}/tests/smoke.lua]]).typescript([[${typescript_fixture}]])"
run_nvim "${typescript_fixture}/tsconfig.json" \
  "+lua dofile([[${REPO_ROOT}/tests/smoke.lua]]).json()"

printf 'Smoke test passed.\n'
