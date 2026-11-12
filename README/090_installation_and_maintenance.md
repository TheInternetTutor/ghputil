# 090 — Installation and Maintenance

## Install from the package

From the extracted package directory, run:

`bash install.sh`

The default destination is `/dir_bash/ghputil`. To install elsewhere:

`bash install.sh /your/utility/path`

The installer copies the main script, functional modules, and configuration template. It sets the installation directory and log directory to owner-only access, shell scripts to mode `600`, and the template to mode `644`. It creates the central `logs/` directory.

The installer is invoked through Bash; the installed scripts are intentionally not executable.

## Source the utility

Use:

`source /dir_bash/ghputil/github_publish.sh --help`

A Bash alias can make this shorter:

`alias GitHubPublish='source /dir_bash/ghputil/github_publish.sh'`

Add the alias to the appropriate Bash startup file if it should persist across sessions. Ensure the alias points to the actual installation path.

## Upgrade

Back up the existing installation and review the new package before replacing installed files. The installer copies the current package files into the destination; it does not manage versioned backups. Preserve project-level `.github-publish.conf` files and the PAT under the home configuration directory—they are not package files and should not be replaced during an upgrade.

## Logs

Logs are stored under:

`/dir_bash/ghputil/logs/`

The project-specific directory is identified using the project name and a path checksum. Keep logs private when they contain local paths, repository names, commit metadata, or other operational details.

## Configuration lifecycle

Each project owns its `.github-publish.conf`. Use `--init` to create it from the installed template. Existing configuration is never overwritten by initialization. To change preferences, edit the project file deliberately and review the values before the next publishing run.

## Maintenance checks

After installing or upgrading:

1. Confirm the expected files exist in the installation directory.
2. Confirm shell scripts are not executable and the template is readable.
3. Run `--help`.
4. Run `--dry-run` against a known project.
5. Confirm the PAT file is readable only by its owner.
6. Confirm SSH authentication to GitHub works independently.
7. Review the latest project-specific log.

## Package contents

A normal source package contains the Bash modules, installer, configuration template, root quick-start README, and modular documentation. It does not need the developer's local `.git` metadata, credentials, or runtime logs.
