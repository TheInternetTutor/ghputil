# Authentication and Security

## Two separate authentication mechanisms

GHPUtil uses a fine-grained GitHub Personal Access Token (PAT) for administrative API requests and SSH for Git operations. These credentials serve different purposes and are not interchangeable.

## PAT location and handling

The token is read from:

`$HOME/.config/github/github_pat.txt`

The file must exist, be readable, and contain a non-empty token. Restrict access to the owner (for example, mode `600` in Cygwin). Do not commit the token, place it in `.github-publish.conf`, embed it in a repository URL, or paste it into logs or chat.

The implementation places the authorization header in a temporary curl configuration file with restrictive permissions rather than passing the token as a curl command-line argument. The temporary directory and file are removed during normal success and failure cleanup. The token is not written to the GHPUtil execution log.

Use a fine-grained token with the minimum GitHub account/repository permissions needed to identify the account, inspect the target repository, and create repositories. Exact permission requirements can change with GitHub's API policy; verify the token configuration against the current GitHub interface if an API operation returns an authorization error.

## GitHub API transport

API calls use HTTPS against `api.github.com`. The utility authenticates the account through `/user`, checks the target repository, and creates a new repository through `/user/repos`. New repositories are created with `auto_init=false` so GitHub does not add an initial README, license, or `.gitignore` commit.

## SSH transport

Git transport uses SSH. If `$HOME/.ssh/config` exists, GHPUtil uses it for the GitHub authentication check and exports a matching `GIT_SSH_COMMAND` for Git operations. Otherwise it uses the normal SSH configuration and identity discovery.

The user's private key remains in the SSH environment. GHPUtil does not copy private-key material into its package or project configuration.

## Project and Git identity separation

`.github-publish.conf` contains publishing preferences only. Git author and committer identities are read from Git's effective configuration. GHPUtil does not hardcode or replace the user's identity and does not rewrite existing commit authorship.

## Operational precautions

- Keep the PAT file private and rotate/revoke the token if it is exposed.
- Do not enable shell tracing (`set -x`) while handling credentials.
- Review logs before sharing them; although the utility is designed not to log the PAT, logs can contain local paths, repository names, and Git metadata.
- Avoid placing the token in environment variables or command arguments when invoking the utility.
