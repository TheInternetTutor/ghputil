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
14. Inspect the remote branch and publish the selected local branch when safe.
15. Verify that the remote branch points to the local commit when verification is enabled.
16. Report the result and clean up temporary API credential files.

The workflow stops when a required precondition or safety check fails. It does not attempt automatic recovery by rewriting local or remote history.

## New repository path

A new repository is created only after the account, repository name, visibility, and authorization are resolved. The repository is created empty, then the local branch is pushed over SSH. A successful run reports the GitHub URL, visibility, branch, commit, and log path.

## Existing repository path

The default existing-repository policy stops before pushing. With explicit `update` authorization, GHPUtil checks the remote branch. If it already points to local HEAD, it reports that no push is necessary. If the remote commit is an ancestor of local HEAD, it performs a normal push. If not, it refuses to push.

## Dry-run behavior

`--dry-run` performs available local and remote inspection but does not create a GitHub repository, add or modify `origin`, or push commits. It reports the detected project, account, repository, branch and commit, existence state, visibility decision, and intended outcome.

A dry run may still contact GitHub to authenticate and inspect repository state. It is therefore not an offline simulation. When visibility is not configured, it reports that a real run would ask the user.

## Verification

When `verify_after_publish=yes` (default), GHPUtil queries the remote branch after the push and compares its commit identifier with the local HEAD. A mismatch is reported as a verification failure. Set `verify_after_publish=no` only when there is a specific reason to skip this final check.

## Logging and cleanup

Each project has a separate log directory under the central installation's `logs/` directory. Logs record workflow steps and diagnostic messages but must not expose the PAT. Temporary API configuration and response files are removed during normal cleanup paths.

## What the workflow deliberately does not do

It does not stage or commit files, clean the working tree, switch branches, replace unrelated remotes, force-push, merge histories, create GitHub initialization commits, or automatically resolve conflicts.
