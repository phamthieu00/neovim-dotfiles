# Maintenance

Keep changes small, reviewable, reversible, documented, and tested.

## Routine update

```bash
git switch -c chore/update-neovim
git pull --ff-only
make update
make doctor
make test
git diff
git status --short
```

`make update` refuses a dirty worktree. It updates lazy.nvim and any plugins
managed in future milestones, then runs health and smoke checks. It does not
create a branch, commit, or update operating-system packages.

There is no repository `lazy-lock.json` while the plugin specification is
empty. When Milestone 2 introduces plugins, commit that lockfile and inspect its
diff during every update.

Avoid combining plugin-manager, language-tooling, and unrelated editor changes
in one update. If an update fails, retain the old lockfile and investigate on
the update branch.

## Before completing any change

```bash
bash -n scripts/*.sh tests/*.sh
make test
make doctor
git diff --check
git status --short
```

Document validation that could not be run and why.
