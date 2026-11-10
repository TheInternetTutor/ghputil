# GitHub Repository Creation and Publishing Utility
## Technical Specification — Version 2.0

**Status:** Draft for review  
**Target environment:** Cygwin on Windows  
**Implementation language:** Bash  
**Primary transport:** Git over SSH  
**GitHub administration:** GitHub REST API over HTTPS  
**Configuration:** Per-project hidden configuration file

---

## 1. Purpose

Develop a reusable command-line utility that creates a GitHub repository when necessary and publishes the committed history of an existing local Git project.

The utility should simplify the process to a single command while retaining conservative defaults, explicit safeguards, and configurable behavior.

The first implementation will target Emilio's Cygwin environment. The architecture should remain modular enough to support additional features and improvements after testing with multiple projects.

## 2. Fundamental Principles

1. **Local project ownership:** The local Git project is the source of truth.
2. **Committed history only:** Publish existing commits. Never automatically stage files or create commits.
3. **Conservative defaults:** Stop rather than overwrite or modify an existing repository unexpectedly.
4. **Explicit authorization:** Repository creation requires confirmation unless configuration or command-line arguments authorize it.
5. **Separation of responsibilities:** Use HTTPS/PAT for GitHub administration and SSH for Git transport.
6. **Preserve history:** Create empty GitHub repositories without automatically initializing README, license, or `.gitignore` files.
7. **Modularity:** Separate configuration, validation, Git inspection, GitHub API operations, and publishing.
8. **Portability:** Project configuration must not contain credentials or machine-specific secrets.

## 3. Operating Environment

The initial implementation must support:

- Cygwin on Windows.
- Bash scripting.
- Git.
- `curl` for GitHub REST API requests.
- SSH for Git transport.
- A fine-grained GitHub Personal Access Token (PAT).

The utility should check for required commands and report missing dependencies before performing operations.

The implementation should avoid requiring GitHub CLI (`gh`).

## 4. Repository Naming and Identification

### 4.1 Default repository name

The default GitHub repository name is derived from the basename of the local Git project directory.

For example, a local project at `/ibkr/trading_intel` maps to:

`TheInternetTutor/trading_intel`

### 4.2 Renamed project directories

If the local project directory is renamed, the new directory name is treated as a new repository name.

The utility must not attempt to infer that a renamed directory represents an existing GitHub repository merely because its Git history or contents are identical.

### 4.3 Name override

The repository name may be overridden through a command-line argument.

## 5. Configuration Architecture

### 5.1 Configuration mechanism

The utility will use only one project-level configuration mechanism:

`.github-publish.conf`

No Git system, global, local, or worktree configuration entries will be used to store utility preferences.

### 5.2 Location and scope

The file resides in the root of the local Git project.

Each project maintains its own configuration independently. Different projects may therefore use different publishing preferences.

### 5.3 Version control

The configuration file is permitted to be committed to Git and shared with project contributors.

It will not be automatically excluded from version control.

### 5.4 Configuration precedence

Settings are resolved in this order:

1. Built-in defaults.
2. Project `.github-publish.conf`.
3. Command-line arguments.

Command-line arguments override the corresponding project configuration values for the current execution. They do not modify the configuration file.

### 5.5 Initial configuration parameters

The initial configuration schema will support:

- `visibility`: `public` or `private`.
- `confirm_create`: `yes` or `no`.
- `existing_repository`: `stop` or `update`.
- `existing_remote`: `reuse` or `stop`.
- `branch`: `master`.
- `verify_after_publish`: `yes` or `no`.

The configuration parser must validate recognized settings and values. Invalid or unknown settings should produce a clear error rather than being silently ignored.

The file must not contain PATs, SSH private keys, or other credentials.

### 5.6 Initial defaults

When no project configuration or command-line override is supplied:

- Visibility: ask the user.
- Repository creation: ask for confirmation.
- Existing GitHub repository: stop and report.
- Existing `origin` remote pointing elsewhere: stop and report.
- Existing `origin` pointing to the intended repository: reuse it.
- Publishing branch: `master`.
- Post-publication verification: enabled.

## 6. Authentication and Security

### 6.1 GitHub API authentication

The utility will use a fine-grained GitHub PAT to perform administrative operations.

The token is stored separately from project configuration at:

`/dir_bash/home/.config/github/github_pat.txt`

The utility must:

- Read the token from that file.
- Never print the token.
- Never include it in command output or diagnostic logs.
- Never place it in Git configuration, project configuration, repository URLs, or commits.
- Report a useful error if the token file is missing, unreadable, or invalid.

The token's required permissions must support repository administration and creation.

### 6.2 Git transport

Git operations will use SSH.

The utility must use the configured SSH identity and connection settings. It must not embed private-key material in the script or project configuration.

### 6.3 Separation of credentials

The following responsibilities remain separate:

- PAT file: GitHub API authentication.
- SSH configuration and private key: Git transport authentication.
- Project configuration: publishing preferences only.
- Git identity configuration: author and committer identity.

## 7. Git Identity and Authorship

The utility must inspect the effective Git author and committer identities.

It must not:

- Hardcode Emilio's identity into the utility.
- Replace the user's global Git identity.
- Rewrite existing commit authorship.
- Automatically create commits.

Git's configured identity must remain authoritative.

The utility should report missing or invalid identity information before publishing when it affects the operation.

## 8. Branch Policy

Version 1 of the utility supports only the `master` branch.

The utility must:

- Verify that the local project is on the supported branch.
- Publish the latest committed state of `master`.
- Stop if the required branch is unavailable.
- Avoid creating, switching, merging, or renaming branches automatically.

A future version may introduce configurable branch policies.

## 9. Local Repository Inspection

Before publishing, the utility must establish:

1. The current directory belongs to a valid Git working tree.
2. The Git project root has been identified.
3. The repository has a valid commit history.
4. The current branch is `master`.
5. The latest commit is identifiable.
6. Git author and committer identity are available.
7. The configured remotes have been inspected.
8. The working tree status has been inspected.

### 9.1 Uncommitted changes

The utility must not stage, commit, stash, discard, or otherwise modify uncommitted changes.

Uncommitted modifications and untracked files remain local and are not included in the publication.

The utility should report their presence so the user understands that only committed history will be published.

## 10. GitHub Repository Discovery and Creation

### 10.1 Account identification

The utility must authenticate with the GitHub API and identify the authenticated account.

The repository will be created under that account.

### 10.2 Repository existence check

Before creating a repository, the utility must check whether the intended repository already exists.

### 10.3 New repository creation

If the repository does not exist:

1. Determine the repository name.
2. Determine visibility from command-line arguments, project configuration, or user input.
3. Request confirmation unless creation has already been authorized.
4. Create the repository through the GitHub REST API.
5. Set the requested visibility.
6. Do not automatically initialize a README, license, or `.gitignore`.
7. Confirm successful creation before proceeding.

### 10.4 Existing repository behavior

The default behavior is `stop`.

If the repository already exists, the utility must report that fact and stop without attempting to push.

An explicit configuration setting or command-line argument may authorize updating an existing repository.

When updating is authorized:

- Inspect the remote repository state.
- Verify that the local and remote histories are compatible.
- Use a normal Git push.
- Never force-push.
- Stop if the histories cannot be reconciled safely.

The utility must not silently overwrite remote content.

## 11. Remote Management

The utility must inspect the local Git remotes before configuring `origin`.

### 11.1 No existing origin

If no `origin` remote exists, configure it to point to the intended GitHub repository using SSH.

### 11.2 Origin points to the intended repository

Reuse the existing remote.

### 11.3 Origin points elsewhere

Stop and report the discrepancy.

Do not automatically replace, delete, or modify an unrelated remote.

### 11.4 SSH verification

Before pushing, verify that SSH authentication to GitHub works.

The utility must stop if authentication fails.

## 12. Publishing Workflow

The expected execution sequence is:

1. Parse command-line arguments.
2. Locate the local Git project root.
3. Load and validate `.github-publish.conf`, if present.
4. Resolve configuration precedence.
5. Validate required dependencies.
6. Inspect the Git repository and current branch.
7. Inspect Git identity, commit history, and working tree status.
8. Inspect existing remotes.
9. Read the PAT from its separate credential file.
10. Authenticate with the GitHub API.
11. Identify the authenticated GitHub account.
12. Check whether the intended repository exists.
13. If it exists, apply the configured existing-repository policy.
14. If it does not exist, determine visibility and obtain authorization.
15. Create the empty GitHub repository.
16. Configure or reuse the SSH remote.
17. Verify SSH authentication.
18. Push the latest committed history on `master`.
19. Verify publication.
20. Report the outcome.

The utility must stop immediately when a required safety condition fails.

## 13. Command-Line Interface

The initial interface should support:

- `--name NAME`: Override the repository name.
- `--visibility public|private`: Set repository visibility.
- `--yes`: Authorize otherwise-confirmable operations, subject to safety checks.
- `--confirm`: Require interactive confirmation for repository creation.
- `--existing stop|update`: Define behavior when the GitHub repository already exists.
- `--dry-run`: Inspect and report the intended actions without creating or modifying remote resources.
- `--help`: Display usage information.

Command-line arguments take precedence over project configuration.

`--yes` must not implicitly authorize updating an existing repository. That behavior requires the explicit `--existing update` setting.

The utility must reject invalid arguments and conflicting options with a clear explanation.

## 14. Dry-Run Mode

Dry-run mode must perform available inspection and validation steps without creating a GitHub repository or pushing commits.

It should report:

- Detected project root.
- Proposed repository name.
- Effective configuration values.
- GitHub account identity, when authentication is available.
- Repository existence status.
- Current branch and latest commit.
- Existing remote configuration.
- Whether publication would proceed or stop.
- The actions that would be performed.

Dry-run must not modify the local Git repository or remote GitHub repository.

## 15. Verification and Reporting

After publication, the utility should verify that the expected branch and commit are available on GitHub.

The final report should identify:

- GitHub account.
- Repository name and URL.
- Repository visibility.
- Local project directory.
- Published branch.
- Published commit identifier.
- Whether the repository was newly created or already existed.
- Whether publication succeeded or failed.

Errors should identify the failed operation and provide enough information to diagnose the problem without exposing credentials.

## 16. Modular Architecture

The implementation should be divided into independent functional modules.

Proposed structure:

- `github_publish.sh` — Main entry point and orchestration.
- `config.sh` — Defaults, configuration-file parsing, argument parsing, and precedence.
- `github_api.sh` — PAT handling, API authentication, repository lookup, and repository creation.
- `git_inspection.sh` — Project discovery, Git identity, branch, commit, status, and remote inspection.
- `git_publish.sh` — SSH verification, remote configuration, push, and publication verification.
- `validation.sh` — Preconditions, input validation, error handling, and safety checks.

The main script should coordinate these modules rather than duplicate their functionality.

Modules should be designed so that future features can be added without requiring a major rewrite.

## 17. Error Handling and Safety Requirements

The utility must stop safely when any of the following occurs:

- The current directory is not inside a valid Git repository.
- The repository has no commits.
- The required branch is missing or unsupported.
- Required dependencies are unavailable.
- Git identity validation fails.
- The PAT file is missing or unreadable.
- GitHub API authentication fails.
- The GitHub API returns an unexpected error.
- Repository creation is denied or unsuccessful.
- An existing remote points to another repository.
- SSH authentication fails.
- Remote history is incompatible with the local history.
- A push fails.
- Post-publication verification fails.

The utility must never force-push, silently replace a remote, or automatically discard local changes.

## 18. Acceptance Criteria

The first implementation will be considered acceptable when the following scenarios work:

1. A local Git project with no GitHub repository can be published successfully.
2. The repository name defaults to the local project directory name.
3. The user can override the repository name.
4. Public and private repository creation both work.
5. The utility can read project-specific settings from `.github-publish.conf`.
6. Command-line arguments override project configuration.
7. A project without a configuration file works using built-in defaults.
8. The configuration file can be committed and shared without exposing credentials.
9. An existing GitHub repository causes the default stop behavior.
10. Explicit authorization allows a compatible existing repository to be updated.
11. An unrelated `origin` remote causes a safe stop.
12. An appropriate existing `origin` remote is reused.
13. Only committed history is published.
14. Uncommitted and untracked files remain untouched.
15. The utility publishes the latest commit on `master`.
16. SSH authentication and GitHub API authentication are handled independently.
17. Dry-run reports the intended workflow without publishing.
18. Successful publication is verified and reported.
19. Errors do not expose the PAT or private-key information.

## 19. Deferred Features

The following are intentionally outside the initial implementation:

- Support for branches other than `master`.
- Automatic staging or committing.
- Automatic conflict resolution or history rewriting.
- Force-pushing.
- Automatic deletion or replacement of remotes.
- Credential encryption or credential-manager integration.
- GitHub organization repositories.
- Multiple GitHub accounts.
- Advanced repository settings such as branch protection, topics, teams, and webhooks.
- Automated synchronization or scheduled publishing.
- A graphical user interface.

These features may be considered after the initial utility has been tested with several projects.

## 20. Version 2.0 Change Record

Version 2.0 establishes the project-level configuration architecture.

Changes from the previous design:

- Removed Git system/global/local configuration as a source of utility preferences.
- Established `.github-publish.conf` as the sole configuration file.
- Made configuration project-specific and independent across repositories.
- Explicitly permitted the configuration file to be committed and shared.
- Established command-line arguments as the highest-precedence settings.
- Kept credentials separate from project configuration.
- Retained the existing repository creation, SSH publishing, safety, and modularity requirements.

---

**End of Specification — Version 2.0**

**Implementation status:** Not yet authorized. This document defines the intended behavior and architecture; code generation will require separate approval.
