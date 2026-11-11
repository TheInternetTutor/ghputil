# GitHub Repository Publisher — v2.1

A modular Bash utility for creating GitHub repositories and publishing committed local Git history.

## Installation

From this package directory, run:

    bash install.sh

The default installation directory is `/dir_bash/github_publish`. An alternate destination may be supplied:

    bash install.sh /some/other/location

## Usage

    /dir_bash/github_publish/github_publish.sh /path/to/project

Preview the workflow without creating or pushing:

    /dir_bash/github_publish/github_publish.sh --dry-run /path/to/project

Override settings for one execution:

    /dir_bash/github_publish/github_publish.sh --visibility private --yes /path/to/project

Update an existing compatible GitHub repository:

    /dir_bash/github_publish/github_publish.sh --existing update /path/to/project

## Project configuration

Copy `github-publish.conf.example` into a project root and rename it:

    .github-publish.conf

Supported keys:

- `visibility=public|private`
- `confirm_create=yes|no`
- `existing_repository=stop|update`
- `existing_remote=reuse|stop`
- `branch=auto|main|master`
- `verify_after_publish=yes|no`

Precedence: built-in defaults, project configuration, command-line arguments.

The configuration file may be committed. It must contain no credentials or machine-specific secrets.

## Credentials and SSH

The PAT is read from:

    $HOME/.config/github/github_pat.txt

SSH authentication uses the user's SSH configuration, if present, and the default GitHub SSH identity.

The PAT file should be readable only by its owner. Never share it, commit it, or paste its contents into a terminal transcript.

## Logs

Execution logs are stored centrally under:

    /dir_bash/github_publish/logs/

Each project receives a separate log directory, identified by its project name and a path checksum.

## Important behavior

- The `main` and `master` branches are supported. By default, the current branch is detected automatically (`branch=auto`). You may explicitly require `branch=main` or `branch=master`.
- Only committed history is published.
- Uncommitted and untracked files are not staged or committed.
- An existing GitHub repository stops by default.
- An unrelated `origin` remote is never replaced.
- No force-push is performed.
- New repositories are created without an automatic README, license, or `.gitignore`.

## Initial test recommendation

1. Install the utility.
2. Run `--help`.
3. Run `--dry-run` against the already-published `trading_intel` project.
4. Test creation with a disposable local Git project and a new repository name.
5. Test the existing-repository stop behavior.
6. Test configuration-file overrides.
7. Test a compatible existing-repository update only after the preceding tests pass.

Review the scripts before running them against important repositories.

## Error handling and terminal behavior

The utility does not call `exit` from its error-reporting function and does not
change the caller's `errexit` or other shell options. Errors are returned
through the functions to the main workflow, which stops and returns a nonzero
status. Temporary API credential files are cleaned up on both success and
failure. When running from an already-open Cygwin terminal, the terminal remains
available after the utility returns. Avoid launching the script by double-
clicking it in a way that creates a disposable terminal window.

The main script resolves its own location with `realpath` and checks that
`realpath` is available as a dependency.

If you want to invoke it from an existing interactive Bash session and keep
running in that same shell after the command returns, you may source it:

    source /dir_bash/github_publish/github_publish.sh /path/to/project

The sourced form returns a status to the current shell; it does not call
`exit`. The normal executable form also avoids `exit` internally and returns a
nonzero process status on failure. For the most predictable terminal behavior,
start Cygwin yourself and run either form from that open terminal.
