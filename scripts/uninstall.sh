#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
SYSTEM="$(uname -s)"
if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then CONFIG_ROOT="${XDG_CONFIG_HOME}"; else CONFIG_ROOT="${HOME}/.config"; fi
if [[ -n "${XDG_DATA_HOME:-}" ]]; then DATA_ROOT="${XDG_DATA_HOME}/nvim"; else DATA_ROOT="${HOME}/.local/share/nvim"; fi
if [[ -n "${XDG_STATE_HOME:-}" ]]; then STATE_ROOT="${XDG_STATE_HOME}/nvim"; else STATE_ROOT="${HOME}/.local/state/nvim"; fi
if [[ -n "${XDG_CACHE_HOME:-}" ]]; then CACHE_ROOT="${XDG_CACHE_HOME}/nvim"; else CACHE_ROOT="${HOME}/.cache/nvim"; fi
CONFIG_LINK="${CONFIG_ROOT}/nvim"

resolve_path() {
  local path="$1" target
  if [[ -L "${path}" ]]; then target="$(readlink "${path}")"; [[ "${target}" = /* ]] || target="$(dirname "${path}")/${target}"; resolve_path "${target}"; else (cd -P "$(dirname "${path}")" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$(basename "${path}")"); fi
}

if [[ -e "${CONFIG_LINK}" || -L "${CONFIG_LINK}" ]]; then
  [[ -L "${CONFIG_LINK}" ]] || { printf 'ERROR: refusing to remove non-symlink path %s\n' "${CONFIG_LINK}" >&2; exit 1; }
  [[ "$(resolve_path "${CONFIG_LINK}")" == "${REPO_ROOT}" ]] || { printf 'ERROR: refusing to remove symlink not owned by this repository: %s\n' "${CONFIG_LINK}" >&2; exit 1; }
  rm -f "${CONFIG_LINK}"; printf 'Removed symlink %s.\n' "${CONFIG_LINK}"
else
  printf 'Configuration symlink is already absent: %s\n' "${CONFIG_LINK}"
fi

marker="${DATA_ROOT}/.neovim-config-owned"
if [[ -f "${marker}" ]] && grep -Fqx "repository=${REPO_ROOT}" "${marker}"; then
  nvim_prefix="$(sed -n 's/^nvim_prefix=//p' "${marker}")"
  nvim_link="$(sed -n 's/^nvim_link=//p' "${marker}")"
  nvim_installed="$(sed -n 's/^nvim_installed=//p' "${marker}")"
  tree_sitter_prefix="$(sed -n 's/^tree_sitter_prefix=//p' "${marker}")"
  tree_sitter_link="$(sed -n 's/^tree_sitter_link=//p' "${marker}")"
  tree_sitter_installed="$(sed -n 's/^tree_sitter_installed=//p' "${marker}")"
  project_plugins=(
    lazy.nvim telescope.nvim plenary.nvim telescope-fzf-native.nvim nvim-treesitter
    nvim-lspconfig mason.nvim mason-lspconfig.nvim blink.cmp conform.nvim
    gitsigns.nvim oil.nvim nvim-autopairs nvim-surround which-key.nvim catppuccin
    nui.nvim noice.nvim bufferline.nvim nvim-web-devicons persistence.nvim
    claude-code.nvim codex.nvim
  )
  mason_packages=(
    lua-language-server typescript-language-server eslint-lsp json-lsp stylua prettierd
  )
  parsers=(lua vim vimdoc bash json yaml javascript typescript tsx markdown markdown_inline)
  for plugin in "${project_plugins[@]}"; do rm -rf "${DATA_ROOT}/lazy/${plugin}"; done
  for package in "${mason_packages[@]}"; do
    rm -rf "${DATA_ROOT}/mason/packages/${package}"
    rm -f "${DATA_ROOT}/mason/bin/${package}"
    rm -f "${DATA_ROOT}/mason/share/mason-schemas/lsp/${package}.json"
  done
  for binary in lua-language-server typescript-language-server vscode-eslint-language-server vscode-json-language-server stylua prettierd; do
    rm -f "${DATA_ROOT}/mason/bin/${binary}"
  done
  for parser in "${parsers[@]}"; do
    rm -f "${DATA_ROOT}/site/parser/${parser}.so" "${DATA_ROOT}/site/parser/${parser}.dll"
    rm -rf "${DATA_ROOT}/site/queries/${parser}"
  done
  rmdir "${DATA_ROOT}/lazy" 2>/dev/null || true
  rm -f "${DATA_ROOT}/.neovim-config-owned"
  rm -rf "${STATE_ROOT}/shada" "${STATE_ROOT}/sessions" "${CACHE_ROOT}/luac" "${CACHE_ROOT}/treesitter"
  if [[ "${nvim_installed}" == true && "${nvim_prefix}" == "${HOME}/.local/opt/nvim-v0.12.3" ]]; then
    [[ "${nvim_link}" == "${HOME}/.local/bin/nvim" ]] || nvim_link=""
    if [[ -L "${nvim_link}" ]] && [[ "$(resolve_path "${nvim_link}")" == "${nvim_prefix}/bin/nvim" ]]; then rm -f "${nvim_link}"; fi
    rm -rf "${nvim_prefix}"
    printf 'Removed the Neovim archive installed by this repository.\n'
  fi
  if [[ "${tree_sitter_installed}" == true && "${tree_sitter_prefix}" == "${HOME}/.local/opt/tree-sitter-v0.26.1" ]]; then
    [[ "${tree_sitter_link}" == "${HOME}/.local/bin/tree-sitter" ]] || tree_sitter_link=""
    if [[ -L "${tree_sitter_link}" ]] && [[ "$(resolve_path "${tree_sitter_link}")" == "${tree_sitter_prefix}/bin/tree-sitter" ]]; then rm -f "${tree_sitter_link}"; fi
    rm -rf "${tree_sitter_prefix}"
    printf 'Removed the tree-sitter CLI installed by this repository.\n'
  fi
  printf 'Removed plugins, Mason packages, and project-owned Neovim cache/state data.\n'
else
  printf 'No ownership marker for this repository was found; plugin/data directories were preserved.\n'
fi

while IFS= read -r backup; do
  [[ -n "${backup}" ]] || continue
  printf 'Backup available (restore manually with mv): %s\n' "${backup}"
done < <(find "${CONFIG_ROOT}" -maxdepth 1 -mindepth 1 -name 'nvim.backup.*' -print 2>/dev/null | sort)
printf 'External tools such as Node.js/npm, Claude, Codex, Homebrew, and project-local dependencies were not removed.\n'
