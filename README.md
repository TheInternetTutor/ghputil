# GitHub Publishing Utility
## Functional Specification — Version 1.0

### 1. Purpose

Create a reusable Bash utility for Cygwin that automates the creation of GitHub repositories and publication of approved local Git repositories.

Emilio is the sole publisher and approval authority. Other contributors and AI assistants may prepare and commit changes, but only Emilio publishes them to GitHub.

### 2. Primary execution

Default command:

`github_publish.sh`

The utility derives the GitHub repository name from the local Git project root directory.

Example:

- Local directory: `/ibkr/trading_intel`
- GitHub repository: `TheInternetTutor/trading_intel`

An optional argument can override the repository name.

### 3. Execution workflow

1. Identify the local Git repository root.
2. Derive the default repository name from its directory.
3. Verify Git installation and repository integrity.
4. Verify the global Git author and committer identities.
5. Inspect local Git configuration and existing remotes.
6. Authenticate against GitHub using HTTPS and the existing PAT.
7. Identify the authenticated GitHub account.
8. Check whether the target repository already exists.
9. If it exists, stop by default and report the situation.
10. If it does not exist, request confirmation unless overridden by configuration or arguments.
11. Ask for repository visibility unless configured or supplied as an argument.
12. Create the GitHub repository.
13. Configure the SSH remote.
14. Verify SSH connectivity.
15. Publish the local `master` branch.
16. Verify the published repository and commit.

### 4. Repository naming and identity

- Default repository name: local Git project root directory name.
- Default owner: authenticated GitHub account.
- No hardcoded GitHub username.
- No hardcoded developer name or email.
- Never configure local `user.name` or `user.email`.
- Use the developer's existing Git configuration.
- Preserve commit author and committer attribution.
- Do not create commits automatically.

### 5. Branch policy

Version 1.0 supports only `master`.

- Publish the latest existing commit on `master`.
- Do not create, merge, or switch branches.
- Do not publish other branches or tags.
- Future versions may introduce configurable branching.

### 6. Commit and source-code policy

The utility publishes committed Git history only.

- Never stage files automatically.
- Never create commits automatically.
- Never upload uncommitted modifications.
- Never upload untracked files.
- Never discard local changes.
- Preserve the existing commit history.

The latest commit on `master` is the publication boundary. The script does not attempt to determine whether a commit is conceptually stable; that is the architect's responsibility.

### 7. Existing GitHub repository policy

Default behavior: STOP.

If the target repository already exists:

- Report its existence.
- Do not create another repository.
- Do not overwrite remote contents.
- Do not push automatically.

An optional future/explicit update policy may permit publishing to an existing repository, provided histories are compatible and the operation is a normal, non-force push.

### 8. Existing remote policy

- If no `origin` exists, configure it.
- If `origin` points to the expected repository, reuse it.
- If `origin` points elsewhere, stop and report the conflict.
- Never silently replace an existing remote.
- Never force-push.

### 9. Repository visibility

Supported values:

- `public`
- `private`

Default: Ask the publisher unless a local configuration or command-line argument supplies the value.

### 10. Authentication

GitHub administration:

- HTTPS REST API.
- Fine-grained Personal Access Token.
- Token file: `/dir_bash/home/.config/github/github_pat.txt`
- Never display or log the token.
- Never place credentials inside the project repository.

Git transport:

- SSH.
- Reuse the publisher's existing SSH configuration.
- Do not generate or replace SSH keys automatically.

Initial implementation uses the existing plaintext token file. GPG encryption is a future enhancement.

### 11. Configuration architecture

Three levels of configuration, with this precedence:

1. Built-in defaults.
2. Per-project local configuration.
3. Command-line arguments.

Command-line arguments override local configuration.

Suggested per-project configuration location:

`.git/github-publish.conf`

This keeps publishing preferences outside the tracked project files.

Configuration should support:

- Repository visibility.
- Confirmation requirements.
- Existing-repository policy.
- Existing-remote policy.
- Branch selection.
- Verification behavior.

No credentials or developer identities belong in this configuration file.

### 12. Command-line interface

Proposed parameters:

- `--name NAME`: Override repository name.
- `--visibility public|private`: Specify visibility.
- `--yes`: Approve routine confirmation prompts.
- `--confirm`: Require interactive confirmation.
- `--existing stop|update`: Control existing-repository behavior.
- `--dry-run`: Inspect and report without changing anything.
- `--help`: Display usage instructions.

The default behavior remains conservative.

### 13. Modular architecture

Suggested modules:

- `github_publish.sh`: Entry point and orchestration.
- `config.sh`: Defaults, local configuration, and argument precedence.
- `github_api.sh`: Authentication, repository lookup, and creation.
- `git_inspection.sh`: Repository, identity, branch, commit, and remote checks.
- `git_publish.sh`: SSH setup and Git publishing.
- `validation.sh`: Preconditions, error handling, and verification.

Each module should have a clearly defined responsibility and should be independently maintainable.

### 14. Safety requirements

- Never delete or overwrite local project files.
- Never force-push.
- Never create commits automatically.
- Never silently change an existing remote.
- Never publish an existing GitHub repository by default.
- Never expose credentials in terminal output.
- Never modify global developer identity.
- Abort on failed authentication or failed validation.
- Report errors clearly and return appropriate exit codes.

### 15. Future enhancements

Potential additions:

- GPG-encrypted credential storage.
- Additional branch support.
- Existing-repository update mode.
- Repository descriptions and metadata.
- Automated GitHub release management.
- More advanced publishing reports.

These are outside the initial implementation unless explicitly authorized.

### 16. Acceptance criteria

Version 1.0 is complete when:

1. A local Git repository can be identified automatically.
2. The repository name is derived correctly.
3. GitHub authentication is verified without exposing the token.
4. Existing repositories are detected.
5. New repositories can be created with the selected visibility.
6. The correct SSH remote is configured or reused.
7. Only committed history from `master` is published.
8. Existing local changes remain untouched.
9. The resulting GitHub repository is verified.
10. Configuration and command-line overrides work as specified.

**End of Specification 1.0**
