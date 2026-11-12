# GHPUtil — GitHub Repository Publisher

GHPUtil publishes the **committed history** of a local Git project to a GitHub repository. It is designed for Bash on Cygwin, uses the GitHub REST API over HTTPS for repository administration, and uses SSH for Git transport.

## Quick start

### 1. Install GHPUtil

From the extracted package directory:

```bash
bash install.sh
```

The default installation is `/dir_bash/ghputil`. To choose another location:

```bash
bash install.sh /your/utility/path
```

### 2. Configure GitHub authentication

Place a fine-grained GitHub Personal Access Token in:

`$HOME/.config/github/github_pat.txt`

Restrict the file so only its owner can read it. See [Authentication and security](README/040_authentication_and_security.md).

### 3. Publish a new local Git project

From a Bash session, source the main script and pass the project directory:

```bash
source /dir_bash/ghputil/github_publish.sh /path/to/project
```

If the project has no `.github-publish.conf`, GHPUtil asks whether to create one from the installed template. Press **Enter** to accept the default **Yes**; publication then continues normally.

To create the configuration separately, without publishing:

```bash
source /dir_bash/ghputil/github_publish.sh --init /path/to/project
```

### 4. Run against a project that already has a GitHub repository

The default policy is to stop when the intended GitHub repository already exists. This is deliberate. To explicitly authorize a compatible update:

```bash
source /dir_bash/ghputil/github_publish.sh --existing update /path/to/project
```

The update still requires compatible history. GHPUtil refuses unrelated histories and never force-pushes. An existing `origin` must point to the intended repository; an unrelated remote is never replaced.

### 5. Preview before publishing

```bash
source /dir_bash/ghputil/github_publish.sh --dry-run /path/to/project
```

A dry run inspects the project and reports the intended actions without creating a GitHub repository, changing `origin`, or pushing.

## Convenient alias

Add this line to your Bash startup file:

```bash
alias GitHubPublish='source /dir_bash/ghputil/github_publish.sh'
```

Then invoke it from any location:

```bash
GitHubPublish ./
GitHubPublish --dry-run ./
GitHubPublish --existing update ./
```

GHPUtil is designed to be sourced. Its shell scripts do not need executable permissions or a `PATH` entry.

## Documentation map

The detailed documentation is in [`README/INDEX.md`](README/INDEX.md). It covers the design, architecture, configuration, credentials, Git safeguards, GitHub repository behavior, workflow, command-line options, installation, and troubleshooting.

## Safety summary

- Only committed history is published. GHPUtil does not stage, commit, stash, or discard files.
- Both `main` and `master` are supported; the current branch is detected by default.
- Existing GitHub repositories stop by default. Updating requires explicit `--existing update` or configuration.
- An unrelated `origin` is never replaced.
- No force-push is performed.
- New GitHub repositories are created without an automatic README, license, or `.gitignore`.
- The project configuration contains preferences, never credentials.

Review the detailed documentation and scripts before using GHPUtil with important repositories.
