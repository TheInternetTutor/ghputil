# GitHub Repository Publisher — v2.2

A modular Bash utility for creating GitHub repositories and publishing committed local Git history.

## Installation

From this package directory, run:

    bash install.sh

The default installation directory is `/dir_bash/ghputil`. An alternate destination may be supplied:

    bash install.sh /some/other/location

## Usage

The utility can be sourced from an interactive Bash session, so its scripts do not need executable permissions and its installation directory does not need to be added to `PATH`:

    source /dir_bash/ghputil/github_publish.sh /path/to/project

A shell alias can shorten this further. For example, add this to your Bash startup file:

    alias GitHubPublish='source /dir_bash/ghputil/github_publish.sh'

Then invoke it from any Git repository with `GitHubPublish ./`. If a project has no `.github-publish.conf`, the utility offers to create one from the installed template (default answer: yes), then continues with publication.

Initialize a project's configuration without publishing:

    source /dir_bash/ghputil/github_publish.sh --init /path/to/project

Preview the workflow without creating or pushing:

    source /dir_bash/ghputil/github_publish.sh --dry-run /path/to/project

Override settings for one execution:

    source /dir_bash/ghputil/github_publish.sh --visibility private --yes /path/to/project

Update an existing compatible GitHub repository:

    source /dir_bash/ghputil/github_publish.sh --existing update /path/to/project

## Project configuration

The utility creates `.github-publish.conf` from the installed `github-publish.conf.example` template when the project configuration is missing. Normal execution asks first and defaults to yes. Use `--init` to create the file and exit without attempting publication. Initialization never overwrites an existing file; it also fails safely if the template is missing or unreadable.

The template is resolved relative to the installed utility, not the current working directory. In non-interactive execution, a missing configuration causes a clear error; initialize it explicitly with `--init` first.

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

    /dir_bash/ghputil/logs/

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
failure. Scripts are installed without executable permissions; source the main
script from an existing Bash session or invoke it explicitly through Bash.

The main script resolves its own location with `realpath` and checks that
`realpath` is available as a dependency.

The sourced form returns a status to the current shell; it does not call
`exit`. For a convenient alias, define one in your Bash startup file, pointing
to the absolute path of the main script.
