# Contributing

This is a personal configuration, but every change should remain understandable
and safe to review.

1. Create a short-lived branch from `main`.
2. Make one logical change and respect the ownership rules in
   `docs/architecture.md`.
3. Update documentation and the changelog when behavior changes.
4. Run `make test`, `make doctor` when relevant, and `git diff --check`.
5. Inspect the committed `lazy-lock.json` separately for every plugin change.
6. Review the complete diff before committing.

Use concise Conventional Commit-style messages when practical:

```text
feat(lsp): add gopls configuration
fix(telescope): correct hidden file search
docs(keymaps): document LSP mappings
chore(plugins): update plugin lockfile
```

Do not mix plugin updates, new language support, and unrelated editor behavior
in one contribution.
