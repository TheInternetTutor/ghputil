# 020 — Architecture and Operating Environment

## Supported environment

The utility is developed for:

- Cygwin on Windows.
- Bash.
- Git.
- `curl` for GitHub REST API requests.
- `ssh` for Git transport and authentication checks.
- `realpath` for resolving the installed script location.
- Standard Cygwin utilities used by the scripts, including `sed`, `tr`, `head`, `mktemp`, `chmod`, `cp`, `ln`, and `rm`.

GitHub CLI (`gh`) is not required.

## Package layout

- `github_publish.sh` — sourced entry point and workflow orchestration.
- `config.sh` — command-line parsing, project configuration, defaults, and effective settings.
- `validation.sh` — shared validation, dependency checks, logging, and error helpers.
- `git_inspection.sh` — project-root discovery, local Git state, branch, identity, and `origin` inspection.
- `github_api.sh` — PAT handling, API requests, account identification, repository lookup, and creation.
- `git_publish.sh` — origin configuration, SSH authentication, push, and post-push verification.
- `github-publish.conf.example` — default project-configuration template.
- `install.sh` — installation and permission setup.
- `README.md` — quick start.
- `README/` — detailed documentation.

## Execution model

The main script resolves its own directory using `realpath`, sources the functional modules from that directory, then runs the workflow. Consequently, the utility does not depend on the caller's current directory for locating its modules or configuration template.

The intended invocation is `source /path/to/github_publish.sh [OPTIONS] PROJECT_DIRECTORY`. Sourcing allows the script to return a status to the caller without closing the interactive shell. The scripts are installed without executable permission; they are Bash source files, not standalone executable commands.

The entry point does not globally enable `errexit` or call `exit` from its normal error path. Functions return status to the orchestrator, which stops the workflow when a required step fails.

## Separation of responsibilities

GHPUtil deliberately uses two independent communication paths:

- HTTPS + PAT: identify the authenticated GitHub account, inspect repository existence, and create a repository.
- SSH: authenticate Git transport and push the local branch.

The local Git configuration remains the source of author/committer identity. GHPUtil does not replace the user's configured Git identity.

## Centralized installation and per-project state

The default installation directory is `/dir_bash/ghputil`. The utility is shared across projects, while `.github-publish.conf` lives in each project's root. Logs are stored centrally under the installation directory, with a separate project-specific log directory.
