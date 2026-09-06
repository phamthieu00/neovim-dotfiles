#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
SYSTEM="$(uname -s)"
if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
  CONFIG_ROOT="${XDG_CONFIG_HOME}"
else
  CONFIG_ROOT="${HOME}/.config"
fi
CONFIG_LINK="${CONFIG_ROOT}/nvim"
ERRORS=0
WARNINGS=0
NVIM="${NVIM_BIN:-$(command -v nvim || true)}"

ok() { printf 'OK: %s\n' "$*"; }
warning() { printf 'WARNING: %s\n' "$*"; WARNINGS=$((WARNINGS + 1)); }
error() { printf 'ERROR: %s\n' "$*" >&2; ERRORS=$((ERRORS + 1)); }

version_at_least() {
  awk -v a="${1#v}" -v b="${2#v}" '
    BEGIN {
      na = split(a, A, "."); nb = split(b, B, ".")
      n = (na > nb ? na : nb)
      for (i = 1; i <= n; i++) {
        x = A[i] + 0; y = B[i] + 0
        if (x > y) exit 0
        if (x < y) exit 1
      }
      exit 0
    }'
}

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

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 is available ($2)."
  else
    error "$1 is required ($2)."
  fi
}

for command_name in git curl tar gzip unzip rg make; do
  check_command "${command_name}" 'Coding MVP dependency'
done

if command -v npm >/dev/null 2>&1; then
  ok "npm is available ($(npm --version))."
else
  error 'npm is required for Node.js tooling.'
fi
if command -v pnpm >/dev/null 2>&1; then
  ok "optional pnpm is available ($(pnpm --version))."
else
  warning 'pnpm is not installed; npm remains fully supported.'
fi
if command -v lazygit >/dev/null 2>&1; then
  ok "lazygit is available ($(lazygit --version | awk -F'version=' '{print $2}' | cut -d, -f1))."
else
  warning 'lazygit is not installed; <leader>gg and :LazyGit will remain unavailable.'
fi

for ai_command in claude codex; do
  if command -v "${ai_command}" >/dev/null 2>&1; then
    ok "${ai_command} CLI is available ($("${ai_command}" --version 2>/dev/null | head -n 1 || true))."
  else
    warning "${ai_command} CLI is not installed; its Neovim integration will remain unavailable until it is on PATH."
  fi
done

if command -v cc >/dev/null 2>&1; then
  ok "C compiler is available ($(cc --version | head -n 1))."
elif command -v gcc >/dev/null 2>&1; then
  ok "C compiler is available ($(gcc --version | head -n 1))."
elif command -v clang >/dev/null 2>&1; then
  ok "C compiler is available ($(clang --version | head -n 1))."
else
  error 'A C compiler (cc, gcc, or clang) is required for Treesitter and Telescope FZF.'
fi

if command -v node >/dev/null 2>&1; then
  node_version="$(node --version | sed 's/^v//')"
  if version_at_least "${node_version}" 22.22.2; then
    ok "Node.js ${node_version} satisfies >= 22.22.2."
  else
    error "Node.js >= 22.22.2 is required; found ${node_version}."
  fi
else
  error 'Node.js >= 22.22.2 is required.'
fi

if command -v tree-sitter >/dev/null 2>&1; then
  tree_sitter_version="$(tree-sitter --version | awk '{print $2}')"
  if version_at_least "${tree_sitter_version}" 0.26.1; then
    ok "tree-sitter CLI ${tree_sitter_version} satisfies >= 0.26.1."
  else
    error "tree-sitter CLI >= 0.26.1 is required; found ${tree_sitter_version}."
  fi
else
  error 'tree-sitter CLI >= 0.26.1 is required.'
fi

if command -v fd >/dev/null 2>&1; then
  ok 'fd is available for fast Telescope file discovery.'
elif command -v fdfind >/dev/null 2>&1; then
  ok 'fdfind is available for fast Telescope file discovery.'
else
  warning 'Neither fd nor fdfind is available; Telescope will fall back to ripgrep.'
fi

if [[ -n "${NVIM}" ]] && "${NVIM}" --headless -u NONE \
  '+if has("nvim-0.12") == 0 | cquit 1 | endif' +qa >/dev/null 2>&1; then
  ok "Neovim 0.12+ is available ($("${NVIM}" --version | head -n 1))."
else
  error 'Neovim 0.12+ is required.'
fi
if [[ -L "${CONFIG_LINK}" ]] && [[ "$(resolve_path "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then
  ok "${CONFIG_LINK} points to this repository."
else
  error "${CONFIG_LINK} does not point to ${REPO_ROOT}; run make install."
fi

run_nvim_check() {
  local description="$1"
  shift
  if [[ -z "${NVIM}" ]]; then
    error "${description}: Neovim is unavailable."
  elif "${NVIM}" --headless "$@" \
    '+lua if vim.v.errmsg ~= "" then vim.cmd("cquit 1") end' +qa >/dev/null 2>&1; then
    ok "${description}"
  else
    error "${description} failed."
  fi
}

check_clipboard() {
  local provider
  if [[ -z "${NVIM}" ]]; then
    warning 'Clipboard provider cannot be checked without Neovim.'
    return
  fi
  provider="$(${NVIM} --headless -u NONE \
    '+lua io.write(vim.fn["provider#clipboard#Executable"]() or "")' +qa 2>/dev/null || true)"
  provider="${provider//$'\n'/}"
  if [[ -n "${provider}" ]] && command -v "${provider}" >/dev/null 2>&1; then
    ok "Clipboard provider ${provider} is available."
  else
    warning 'No usable system clipboard provider was found; use Vim registers or install wl-clipboard/xclip/xsel.'
  fi
}

check_clipboard

run_health() {
  local provider="$1" lazy_plugin="${2:-}" health_output
  health_output="$(mktemp)"
  local -a args=("+checkhealth ${provider}" "+silent write! ${health_output}" +qa)
  [[ -z "${lazy_plugin}" ]] || args=("+Lazy! load ${lazy_plugin}" "${args[@]}")
  if "${NVIM}" --headless "${args[@]}" \
    '+lua if vim.v.errmsg ~= "" then vim.cmd("cquit 1") end' >/dev/null 2>&1 \
    && ! rg --quiet '❌ ERROR|ERROR No healthcheck' "${health_output}"; then
    ok ":checkhealth ${provider} completed."
  else
    error ":checkhealth ${provider} failed; output follows."
    sed 's/^/  /' "${health_output}" >&2
  fi
  rm -f "${health_output}"
}

if [[ -n "${NVIM}" && -L "${CONFIG_LINK}" ]] \
  && [[ "$(resolve_path "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then
  run_nvim_check 'Neovim starts with the installed configuration.'
  run_nvim_check 'Coding modules load.' \
    '+Lazy! load bufferline.nvim nvim-web-devicons persistence.nvim claude-code.nvim codex.nvim' \
    "+lua assert(require('telescope') and require('blink.cmp') and require('conform') and require('gitsigns') and require('nvim-treesitter') and require('oil') and require('nvim-autopairs') and require('nvim-surround') and require('which-key') and require('catppuccin') and require('noice') and require('bufferline') and require('nvim-web-devicons') and require('persistence') and require('claude-code') and require('codex') and vim.g.colors_name == 'catppuccin-mocha')"
  run_nvim_check 'LSP configurations resolve.' \
    '+Lazy! load nvim-lspconfig mason.nvim mason-lspconfig.nvim' \
    "+lua for _,n in ipairs({'lua_ls','ts_ls','eslint','jsonls'}) do assert(vim.lsp.config[n], n .. ' config unavailable') end"
  run_nvim_check 'Required Mason packages are installed.' \
    '+Lazy! load mason.nvim' \
    "+lua local r=require('mason-registry'); for _,n in ipairs({'lua-language-server','typescript-language-server','eslint-lsp','json-lsp','stylua','prettierd'}) do assert(r.is_installed(n), n .. ' is not installed') end"
  run_nvim_check 'Required Treesitter parsers are installed.' \
    "+lua local i=require('nvim-treesitter').get_installed(); local s={}; for _,n in ipairs(i) do s[n]=true end; for _,n in ipairs({'lua','vim','vimdoc','bash','json','yaml','javascript','typescript','tsx','markdown','markdown_inline'}) do assert(s[n], n .. ' parser is not installed') end"
  run_nvim_check 'Conform formatters are available.' \
    '+Lazy! load mason.nvim conform.nvim' \
    "+lua local c=require('conform'); assert(c.get_formatter_info('stylua').available, 'stylua unavailable'); assert(c.get_formatter_info('prettierd').available, 'prettierd unavailable')"
  run_health vim.lsp nvim-lspconfig
  run_health telescope telescope.nvim
  run_health vim.treesitter
  run_health mason mason.nvim
  run_health which-key which-key.nvim
  run_health noice noice.nvim
fi

printf 'Doctor summary: %d error(s), %d warning(s).\n' "${ERRORS}" "${WARNINGS}"
((ERRORS == 0))
