# 030 — Configuration and Settings

## Project configuration file

Each Git project may contain one configuration file in its repository root:

`.github-publish.conf`

The file uses simple `key=value` lines. Blank lines and text following `#` are ignored. Whitespace around keys and values is trimmed. Unknown keys, malformed lines, and invalid values cause an error rather than being silently ignored.

The file may be committed and shared. It must contain preferences only—never a PAT, SSH private key, or other secret.

## Supported settings

- `visibility=public|private` — visibility used when creating a new repository. If empty or unspecified, the user is asked during an interactive run.
- `confirm_create=yes|no` — whether creation of a new repository requires an interactive confirmation. Default: `yes`.
- `existing_repository=stop|update` — action when the intended GitHub repository already exists. Default: `stop`.
- `existing_remote=reuse|stop` — whether a matching existing `origin` is reused or any existing `origin` causes a stop. Default: `reuse`.
- `branch=auto|main|master` — branch selection. Default: `auto`, which selects the current branch when it is `main` or `master`.
- `verify_after_publish=yes|no` — whether the remote branch is checked against the local commit after pushing. Default: `yes`.

The installed template currently sets `visibility=public`, `confirm_create=yes`, `existing_repository=stop`, `existing_remote=reuse`, `branch=auto`, and `verify_after_publish=yes`. A project can edit these values to establish its own preferences.

## Configuration precedence

Effective settings are resolved in this order:

1. Built-in defaults.
2. Project `.github-publish.conf`.
3. Command-line options for the current invocation.

Command-line overrides do not rewrite the project configuration.

## Automatic initialization

If the project configuration is missing during normal interactive execution, GHPUtil asks:

`Configuration file not found. Create it from the default template? [Y/n]`

Pressing Enter accepts the default Yes. On successful creation, GHPUtil continues with the normal publishing workflow. Answering No cancels the run without creating the file.

The template is located relative to the installed utility, not the current working directory. If the template is missing or unreadable, initialization fails safely. A missing config in a non-interactive run also fails clearly; use `--init` first or create the file manually.

Initialization never overwrites an existing config. It prepares a temporary file inside the project directory and uses an atomic link operation to avoid replacing a file created concurrently.

## Standalone initialization

Use:

`source /dir_bash/ghputil/github_publish.sh --init /path/to/project`

This creates `.github-publish.conf` if missing and exits the utility without contacting GitHub or publishing. If the file already exists, it is preserved and the command reports that fact. `--init` cannot be combined with publishing options.

## Example

```ini
visibility=private
confirm_create=no
existing_repository=stop
existing_remote=reuse
branch=auto
verify_after_publish=yes
```

This example authorizes creation of a new private repository without a separate creation prompt, while retaining the default stop behavior for an existing repository. It does not authorize updating an existing repository.
