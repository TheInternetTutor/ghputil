# Troubleshooting and Limitations

## Configuration is missing

For an interactive run, answer Yes (or press Enter) when asked to create `.github-publish.conf`. To initialize without publishing, use `--init`. In a non-interactive run, initialize the file beforehand or create it manually. If initialization fails, verify that the installed `github-publish.conf.example` exists and is readable.

## GitHub API authentication fails

Check that `$HOME/.config/github/github_pat.txt` exists, is readable, and contains a valid fine-grained PAT. Verify that the token has the permissions required for account identification, repository inspection, and repository creation. Do not paste the token into diagnostics. An HTTP authorization error generally indicates token validity, expiration, or permission scope; an HTTP transport failure may indicate connectivity or TLS problems.

## SSH authentication fails

Test SSH authentication independently using the same SSH configuration that GHPUtil uses. Check the key path, file permissions, SSH agent state if applicable, and the GitHub account to which the public key is registered. Remember that API authentication and SSH authentication are separate.

## Existing repository causes a stop

This is the default safety policy. If the repository is the intended one and you want to update it, use `--existing update` or set `existing_repository=update` in the project config. The remote branch must still be a compatible ancestor of the local commit. `--yes` alone does not change this policy.

## Origin points to another repository

GHPUtil intentionally stops rather than replacing `origin`. Inspect the remote with Git and decide manually whether the local project is associated with the intended repository. Do not change the remote merely to bypass the safeguard.

## Branch is unsupported or mismatched

Only `main` and `master` are supported. With `branch=auto`, GHPUtil selects the current supported branch. If the configuration explicitly names a different supported branch than the current branch, set it to `auto` or change it to match the current branch. GHPUtil does not switch branches.

## Push rejected due to remote history

GHPUtil refuses to force-push. If the remote commit is not an ancestor of local HEAD, stop and inspect both histories manually. Resolve the history relationship using normal Git operations, review the resulting commits, then run GHPUtil again. The utility does not merge or rewrite history automatically.

## Dry-run does not create a repository

That is intentional. Dry-run may authenticate to GitHub and inspect the repository, but it does not create remote resources, add `origin`, or push.

## Known limitations

- Supports Cygwin/Bash and the `main` or `master` branch; other branches are rejected.
- Uses one authenticated GitHub account at a time, as identified by the PAT.
- The PAT is stored as a plaintext file. Encryption or credential-manager integration is not implemented.
- Organization repository creation, multiple-account selection, branch protection, topics, teams, webhooks, GUI support, scheduled synchronization, and automated conflict resolution are outside the current scope.
- It is a publisher, not a bidirectional synchronization or backup system.
- ShellCheck was not available during the v2.2 validation; syntax and functional tests were performed separately.

## Diagnostic information to retain

When investigating a failure, record the GHPUtil version, command options (excluding secrets), effective configuration values, relevant log excerpt, current branch, latest commit, and sanitized remote URL. Never include the PAT or private SSH key material.
