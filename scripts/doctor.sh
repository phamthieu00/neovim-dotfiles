#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
CONFIG_LINK="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
ERRORS=0
WARNINGS=0

ok() {
  printf 'OK: %s\n' "$*"
}

warning() {
  printf 'WARNING: %s\n' "$*"
  ((WARNINGS += 1)) || true
}

error() {
  printf 'ERROR: %s\n' "$*" >&2
  ((ERRORS += 1)) || true
}

version_at_least() {
  local actual="$1"
  local required="$2"
  [[ "$(printf '%s\n%s\n' "${required}" "${actual}" | sort -V | head -n 1)" == "${required}" ]]
}

check_command() {
  local command_name="$1"
  local purpose="$2"
  if command -v "${command_name}" >/dev/null 2>&1; then
    ok "${command_name} is available (${purpose})."
  else
    error "${command_name} is required (${purpose})."
  fi
}

NVIM="${NVIM_BIN:-$(command -v nvim || true)}"

for command_name in git curl tar gzip unzip rg make; do
  check_command "${command_name}" "Coding MVP dependency"
done

if command -v npm >/dev/null 2>&1; then
  ok "npm is available ($(npm --version))."
else
  error "npm is required for Node.js tooling."
fi

if command -v pnpm >/dev/null 2>&1; then
  ok "optional pnpm is available ($(pnpm --version))."
else
  warning "pnpm is not installed; npm remains fully supported."
fi

if command -v cc >/dev/null 2>&1; then
  ok "C compiler is available ($(cc --version | head -n 1))."
elif command -v gcc >/dev/null 2>&1; then
  ok "C compiler is available ($(gcc --version | head -n 1))."
elif command -v clang >/dev/null 2>&1; then
  ok "C compiler is available ($(clang --version | head -n 1))."
else
  error "A C compiler (cc, gcc, or clang) is required for Treesitter and Telescope FZF."
fi

if command -v node >/dev/null 2>&1; then
  node_version="$(node --version | sed 's/^v//')"
  if version_at_least "${node_version}" "22.22.2"; then
    ok "Node.js ${node_version} satisfies >= 22.22.2."
  else
    error "Node.js >= 22.22.2 is required; found ${node_version}."
  fi
else
  error "Node.js >= 22.22.2 is required."
fi

if command -v tree-sitter >/dev/null 2>&1; then
  tree_sitter_version="$(tree-sitter --version | awk '{print $2}')"
  if version_at_least "${tree_sitter_version}" "0.26.1"; then
    ok "tree-sitter CLI ${tree_sitter_version} satisfies >= 0.26.1."
  else
    error "tree-sitter CLI >= 0.26.1 is required; found ${tree_sitter_version}."
  fi
else
  error "tree-sitter CLI >= 0.26.1 is required."
fi

if command -v fd >/dev/null 2>&1; then
  ok "fd is available for fast Telescope file discovery."
elif command -v fdfind >/dev/null 2>&1; then
  ok "fdfind is available for fast Telescope file discovery."
else
  warning "Neither fd nor fdfind is available; Telescope will fall back to ripgrep."
fi

if [[ -n "${NVIM}" ]] && "${NVIM}" --headless -u NONE \
  '+if has("nvim-0.12") == 0 | cquit 1 | endif' +qa >/dev/null 2>&1; then
  ok "Neovim 0.12+ is available ($("${NVIM}" --version | head -n 1))."
else
  error "Neovim 0.12+ is required."
fi

if [[ -L "${CONFIG_LINK}" ]] && [[ "$(readlink -f -- "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then
  ok "${CONFIG_LINK} points to this repository."
else
  error "${CONFIG_LINK} does not point to ${REPO_ROOT}; run make install."
fi

run_nvim_check() {
  local description="$1"
  shift
  if "${NVIM}" --headless "$@" \
    '+lua if vim.v.errmsg ~= "" then vim.cmd("cquit 1") end' +qa >/dev/null 2>&1; then
    ok "${description}"
  else
    error "${description} failed."
  fi
}

run_health() {
  local provider="$1"
  local lazy_plugin="${2:-}"
  local health_output
  local -a nvim_args=()
  health_output="$(mktemp)"

  if [[ -n "${lazy_plugin}" ]]; then
    nvim_args+=("+Lazy! load ${lazy_plugin}")
  fi

  if "${NVIM}" --headless "${nvim_args[@]}" \
    "+checkhealth ${provider}" "+silent write! ${health_output}" +qa >/dev/null 2>&1 \
    && ! rg --quiet '❌ ERROR|ERROR No healthcheck' "${health_output}"; then
    ok ":checkhealth ${provider} completed."
  else
    error ":checkhealth ${provider} failed; output follows."
    sed 's/^/  /' "${health_output}" >&2
  fi
  rm -f -- "${health_output}"
}

if [[ -n "${NVIM}" && -L "${CONFIG_LINK}" ]] \
  && [[ "$(readlink -f -- "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then
  run_nvim_check "Neovim starts with the installed configuration."
  run_nvim_check "Coding MVP modules load." \
    "+lua assert(require('telescope') and require('blink.cmp') and require('conform') and require('gitsigns') and require('nvim-treesitter'))"
  run_nvim_check "LSP configurations resolve." \
    "+Lazy! load nvim-lspconfig mason.nvim mason-lspconfig.nvim" \
    "+lua for _,n in ipairs({'lua_ls','ts_ls','eslint','jsonls'}) do assert(vim.lsp.config[n], n .. ' config unavailable') end"
  run_nvim_check "Required Mason packages are installed." \
    "+Lazy! load mason.nvim" \
    "+lua local r=require('mason-registry'); for _,n in ipairs({'lua-language-server','typescript-language-server','eslint-lsp','json-lsp','stylua','prettierd'}) do assert(r.is_installed(n), n .. ' is not installed') end"
  run_nvim_check "Required Treesitter parsers are installed." \
    "+lua local i=require('nvim-treesitter').get_installed(); local s={}; for _,n in ipairs(i) do s[n]=true end; for _,n in ipairs({'lua','vim','vimdoc','bash','json','yaml','javascript','typescript','tsx','markdown','markdown_inline'}) do assert(s[n], n .. ' parser is not installed') end"
  run_nvim_check "Conform formatters are available." \
    "+Lazy! load mason.nvim conform.nvim" \
    "+lua local c=require('conform'); assert(c.get_formatter_info('stylua').available, 'stylua unavailable'); assert(c.get_formatter_info('prettierd').available, 'prettierd unavailable')"

  run_health vim.lsp nvim-lspconfig
  run_health telescope telescope.nvim
  run_health vim.treesitter
  run_health mason mason.nvim
fi

printf 'Doctor summary: %d error(s), %d warning(s).\n' "${ERRORS}" "${WARNINGS}"
((ERRORS == 0))
