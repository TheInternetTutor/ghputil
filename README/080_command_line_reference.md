# Command-Line Reference

## Syntax

`source /dir_bash/ghputil/github_publish.sh [OPTIONS] PROJECT_DIRECTORY`

Exactly one project directory is required for normal operation. The script may also be sourced through an alias.

## Options

- `--name NAME` — Override the GitHub repository name for this run.
- `--visibility public|private` — Set visibility for a new repository.
- `--yes` — Authorize repository creation without the creation prompt. Does not authorize updating an existing repository.
- `--confirm` — Require interactive confirmation for repository creation. Cannot be combined with `--yes`.
- `--existing stop|update` — Select behavior when the intended GitHub repository already exists. Default: `stop`.
- `--dry-run` — Inspect and report without creating remote resources, changing `origin`, or pushing.
- `--init` — Create `.github-publish.conf` from the installed template and exit. Cannot be combined with publishing options.
- `--help`, `-h` — Display usage information.

## Examples

Show help:

`source /dir_bash/ghputil/github_publish.sh --help`

Publish the current project directory:

`source /dir_bash/ghputil/github_publish.sh ./`

Preview a project:

`source /dir_bash/ghputil/github_publish.sh --dry-run ./`

Initialize configuration only:

`source /dir_bash/ghputil/github_publish.sh --init ./`

Create a private repository and skip the creation prompt:

`source /dir_bash/ghputil/github_publish.sh --visibility private --yes ./`

Explicitly authorize an update of an existing repository:

`source /dir_bash/ghputil/github_publish.sh --existing update ./`

Override the default repository name:

`source /dir_bash/ghputil/github_publish.sh --name my_repository ./`

## Option precedence and restrictions

Command-line values override the corresponding project configuration for the current run. `--yes` and `--confirm` conflict. `--init` is an initialization-only operation and cannot be combined with publishing options. Unknown options, invalid enumerated values, and multiple project-directory arguments are rejected.

The visibility option affects repository creation; it does not change the visibility of an existing repository. The `--existing update` option does not bypass remote-history compatibility checks.

## Alias usage

Define this alias in the Bash startup file:

`alias GitHubPublish='source /dir_bash/ghputil/github_publish.sh'`

Then:

- `GitHubPublish ./`
- `GitHubPublish --help ./`
- `GitHubPublish --dry-run ./`
- `GitHubPublish --existing update ./`

The alias sources the script in the current Bash session. No executable bit or `PATH` entry is required.
