# 060 — GitHub Repository Management

## Repository name

By default, the GitHub repository name is the basename of the local project directory. For example, `/ibkr/trading_intel` maps to `TheInternetTutor/trading_intel` when the authenticated account is `TheInternetTutor`.

Use `--name NAME` to override the name for one invocation. Names are limited to letters, numbers, dots, underscores, and hyphens. Renaming a local project directory changes the default proposed repository name; GHPUtil does not infer repository identity from matching contents or Git history.

## Account and existence discovery

GHPUtil uses the PAT to identify the authenticated GitHub account, then checks whether the intended repository exists under that account. The account identity returned by GitHub—not a hardcoded username—is used to construct the repository URL.

## Creating a new repository

When the repository does not exist, GHPUtil resolves visibility from command-line options or project configuration. If visibility is unspecified, an interactive run asks for `public` or `private`.

Creation requires confirmation by default. `confirm_create=no` or `--yes` authorizes creation without that prompt. The API creates an empty repository and does not initialize a README, license, or `.gitignore`.

## Existing GitHub repository

The default policy is `existing_repository=stop`. GHPUtil reports the existing repository and stops without pushing. Updating requires explicit authorization through either:

- `existing_repository=update` in the project configuration; or
- `--existing update` on the command line.

`--yes` is not an authorization to update an existing repository. If updating is authorized, GHPUtil checks the target branch. If the remote branch is already at the local commit, no push is needed. Otherwise, the remote commit must be an ancestor of the local HEAD. Divergent or unrelated history is rejected. Pushes are ordinary, non-force pushes.

## Origin remote policy

- No `origin`: GHPUtil adds the intended SSH URL when the workflow reaches remote configuration.
- Matching `origin`: reuse it by default.
- `existing_remote=stop`: stop if any `origin` is already configured.
- `origin` points to another repository: stop. GHPUtil never silently replaces or deletes it.

The intended SSH URL has the form:

`git@github.com:ACCOUNT/REPOSITORY.git`

Existing matching HTTPS and SSH forms are normalized for comparison. The actual remote is reused rather than rewritten.

## No force-push and no history rewriting

GHPUtil does not force-push, reset the remote, rewrite history, or resolve conflicts automatically. If the remote and local histories cannot be reconciled by a safe fast-forward push, the operation stops and leaves the user to resolve the repository state manually.
