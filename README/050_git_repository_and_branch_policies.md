# 050 — Git Repository and Branch Policies

## Project discovery and prerequisites

The supplied project path must resolve to a Git working tree. GHPUtil identifies the repository root and inspects its current branch, latest commit, author and committer identities, working-tree status, and configured remotes.

A repository must have at least one commit. Detached HEAD is rejected. The effective Git author and committer identities must be available.

## Supported branches

The current implementation supports `main` and `master` only.

- `branch=auto` (default): publish the current branch if it is `main` or `master`.
- `branch=main`: require the current branch to be `main`.
- `branch=master`: require the current branch to be `master`.

An explicitly configured branch that differs from the current branch causes a safe stop. GHPUtil does not switch branches, create branches, rename branches, merge, or publish an arbitrary feature branch.

This replaces the original v2.0 specification's `master`-only proposal. Branch auto-detection and `main` support were implemented later.

## Committed history only

GHPUtil publishes the current branch's committed HEAD. It does not stage, commit, stash, reset, clean, or discard local files. Modified, staged, and untracked content remains local and is not included in the push. The utility reports when the working tree is not clean so the user understands the distinction.

## Git identity

The effective Git author and committer identities are checked before publishing. GHPUtil does not set global or local identity values and does not rewrite commit metadata.

## Local state remains under user control

GHPUtil may add `origin` when no origin exists and may push the selected branch. It does not otherwise alter project content or automatically repair a Git repository. Review the project state before publishing, especially when local changes are pending.
