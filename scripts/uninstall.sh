#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
CONFIG_ROOT="${XDG_CONFIG_HOME:-${HOME}/.config}"
CONFIG_LINK="${CONFIG_ROOT}/nvim"

if [[ ! -e "${CONFIG_LINK}" && ! -L "${CONFIG_LINK}" ]]; then
  printf 'Nothing to remove: %s does not exist.\n' "${CONFIG_LINK}"
  exit 0
fi

if [[ ! -L "${CONFIG_LINK}" ]]; then
  printf 'ERROR: refusing to remove non-symlink path %s\n' "${CONFIG_LINK}" >&2
  exit 1
fi

if [[ "$(readlink -f -- "${CONFIG_LINK}")" != "${REPO_ROOT}" ]]; then
  printf 'ERROR: refusing to remove symlink not owned by this repository: %s\n' "${CONFIG_LINK}" >&2
  exit 1
fi

rm -- "${CONFIG_LINK}"
printf 'Removed symlink %s.\n' "${CONFIG_LINK}"
printf 'Neovim data, state, and cache directories were preserved.\n'

mapfile -t backups < <(find "${CONFIG_ROOT}" -maxdepth 1 -mindepth 1 -name 'nvim.backup.*' -print | sort)
if ((${#backups[@]} > 0)); then
  printf 'Available backups (restore one manually by moving it to %s):\n' "${CONFIG_LINK}"
  printf '  %s\n' "${backups[@]}"
fi
