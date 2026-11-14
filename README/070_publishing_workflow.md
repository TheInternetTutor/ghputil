# Publishing Workflow

## Normal execution sequence

A normal publishing run follows this general order:

1. Parse command-line arguments and resolve the project directory.
2. Initialize project-specific logging.
3. Locate or initialize `.github-publish.conf`.
4. Load and validate project settings, then apply command-line overrides.
5. Validate required dependencies.
6. Inspect the local Git repository, supported branch, latest commit, Git identity, and working-tree status.
7. Read the PAT and authenticate to the GitHub API.
8. Identify the authenticated GitHub account.
9. Inspect local `origin` and check whether the intended GitHub repository exists.
10. Apply the configured existing-repository policy.
11. If needed, resolve visibility and obtain authorization, then create the empty repository.
12. Add or reuse the matching SSH `origin`.
13. Verify SSH authentication to GitHub.
14. Inspect the remote branch and retrieve its commit objects when the branch exists.
15. Compare local and remote ancestry. Publish normally when the remote is an ancestor of local HEAD; create a remote recovery snapshot and stop when remote-only commits exist.
16. Verify a successful push when verification is enabled.
17. Report the result and clean up temporary API credential files.

The workflow stops when a required precondition or safety check fails. It does not attempt automatic recovery by rewriting local or remote history.

## New repository path

A new repository is created only after the account, repository name, visibility, and authorization are resolved. The repository is created empty, then the local branch is pushed over SSH. A successful run reports the GitHub URL, visibility, branch, commit, and log path.

## Existing repository path

The default existing-repository policy stops before pushing. With explicit `update` authorization, GHPUtil checks the remote branch and fetches its objects into a temporary private ref without checking out or merging them.

- If remote HEAD equals local HEAD, no push is necessary.
- If remote HEAD is an ancestor of local HEAD, GHPUtil performs a normal push.
- If remote HEAD is ahead of local HEAD, GHPUtil creates an incremental bundle containing commits after the common ancestor.
- If histories have diverged, the bundle contains the remote-only commits after the common ancestor; local-only commits are not included.

For either remote-ahead case, GHPUtil verifies the bundle in a temporary shared repository, fetches from the bundle, and extracts only remote-changed file versions into `PROJECT_ROOT/GHPUtil-Remote/`, preserving their repository-relative paths. `GHPUtil-Remote-Manifest.txt` records the branch, common ancestor, remote commit, local commit at detection, and Git change-status list. Deleted paths are recorded in the manifest because deleted files have no remote file contents to extract. Renames are represented by Git's name-status output and the new remote path is extracted.

The temporary bundle is deleted only after extraction and path verification succeed. If an operation fails after bundle creation, the bundle is retained for diagnosis. Existing `GHPUtil-Remote/` directories and bundle files are never overwritten; remove or rename them yourself before another recovery attempt. After extraction, GHPUtil stops with: “The remote bundle is ready for comparison and integration with the local repository.” It does not push, merge, rebase, reset, stage, commit, or overwrite local project files in this recovery path.

## Dry-run behavior

`--dry-run` performs available local and remote inspection but does not create a GitHub repository, add or modify `origin`, or push commits. It reports the detected project, account, repository, branch and commit, existence state, visibility decision, and intended outcome.

A dry run may still contact GitHub to authenticate and inspect repository state. It is therefore not an offline simulation. When visibility is not configured, it reports that a real run would ask the user.

## Verification

When `verify_after_publish=yes` (default), GHPUtil queries the remote branch after the push and compares its commit identifier with the local HEAD. A mismatch is reported as a verification failure. Set `verify_after_publish=no` only when there is a specific reason to skip this final check.

## Logging and cleanup

Each project has a separate log directory under the central installation's `logs/` directory. Logs record workflow steps and diagnostic messages but must not expose the PAT. Temporary API configuration and response files are removed during normal cleanup paths.

## What the workflow deliberately does not do

It does not stage or commit files, clean the working tree, switch branches, replace unrelated remotes, force-push, merge histories, create GitHub initialization commits, or automatically resolve conflicts. The remote recovery directory is deliberately left for manual comparison and integration; add `GHPUtil-Remote/` to `.gitignore` yourself if appropriate.
