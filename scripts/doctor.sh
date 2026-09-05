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
  ((WARNINGS += 1))
}

error() {
  printf 'ERROR: %s\n' "$*" >&2
  ((ERRORS += 1))
}

NVIM="${NVIM_BIN:-$(command -v nvim || true)}"

if command -v git >/dev/null 2>&1; then
  ok "git is available ($(git --version))."
else
  error "git is required to bootstrap lazy.nvim."
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

if [[ -n "${NVIM}" && -L "${CONFIG_LINK}" ]] \
  && [[ "$(readlink -f -- "${CONFIG_LINK}")" == "${REPO_ROOT}" ]]; then
  if "${NVIM}" --headless +qa >/dev/null 2>&1; then
    ok "Neovim starts with the installed configuration."
  else
    error "Neovim failed to start with the installed configuration."
  fi

  health_output="$(mktemp)"
  if "${NVIM}" --headless '+checkhealth' +qa >"${health_output}" 2>&1; then
    ok "Neovim health checks completed."
  else
    error "Neovim health checks failed; output follows."
    sed 's/^/  /' "${health_output}" >&2
  fi
  rm -f -- "${health_output}"
fi

for command_name in rg node npm gcc make tree-sitter; do
  if command -v "${command_name}" >/dev/null 2>&1; then
    ok "optional future tool ${command_name} is available."
  else
    warning "optional future tool ${command_name} is not installed."
  fi
done

if command -v fd >/dev/null 2>&1; then
  ok "optional future tool fd is available."
elif command -v fdfind >/dev/null 2>&1; then
  warning "fdfind is available, but a future Telescope setup will expect an fd command."
else
  warning "optional future tool fd is not installed."
fi

printf 'Doctor summary: %d error(s), %d warning(s).\n' "${ERRORS}" "${WARNINGS}"
((ERRORS == 0))
