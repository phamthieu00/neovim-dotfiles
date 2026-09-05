#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
NVIM="${NVIM_BIN:-$(command -v nvim || true)}"

cd -- "${REPO_ROOT}"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { printf 'ERROR: update must run inside a Git worktree.\n' >&2; exit 1; }

if [[ -n "$(git status --porcelain)" ]]; then
  printf 'ERROR: commit or stash current changes before updating.\n' >&2
  exit 1
fi

if [[ -z "${NVIM}" ]] || ! "${NVIM}" --headless -u NONE \
  '+if has("nvim-0.12") == 0 | cquit 1 | endif' +qa >/dev/null 2>&1; then
  printf 'ERROR: Neovim 0.12+ is required.\n' >&2
  exit 1
fi

printf 'Updating lazy.nvim and managed plugins.\n'
"${NVIM}" --headless '+Lazy! update' +qa
NVIM_BIN="${NVIM}" "${SCRIPT_DIR}/doctor.sh"
NVIM_BIN="${NVIM}" "${REPO_ROOT}/tests/smoke-test.sh"

printf '\nRepository changes after update:\n'
git status --short
if [[ -f lazy-lock.json ]]; then
  git diff -- lazy-lock.json
else
  printf 'No lazy-lock.json exists yet; it will be introduced with managed plugins.\n'
fi
