# Purpose and Design Principles

## Purpose

GHPUtil is a reusable Bash utility that creates a GitHub repository when needed and publishes the committed history of an existing local Git project. It reduces a multi-step publishing task to one command while keeping local project ownership and conservative safety checks intact.

The initial target is Emilio's Cygwin environment. The design separates GitHub administration from Git transport so repository management uses the GitHub REST API over HTTPS while commit transfer uses Git over SSH.

## The original problem

Publishing a local repository manually involves identifying the project, choosing a remote name, checking whether a GitHub repository already exists, creating it without initializing conflicting files, configuring SSH transport, and pushing the correct branch. Repeating these steps across projects creates opportunities for mistakes—especially accidental pushes to the wrong repository or overwriting remote history.

GHPUtil centralizes that workflow and applies the same safeguards to each project.

## Governing principles

1. **The local repository is authoritative.** GHPUtil publishes the local committed history; it does not take ownership of project content.
2. **Committed history only.** It never stages, commits, stashes, or discards files. Uncommitted and untracked content stays local.
3. **Stop safely by default.** Existing GitHub repositories stop unless updating is explicitly authorized.
4. **No silent remote replacement.** An unrelated `origin` is a conflict, not an invitation to rewrite configuration.
5. **No force-push.** Existing remote history must be compatible with the local branch.
6. **Explicit authorization.** Repository creation and existing-repository updates are separate decisions. `--yes` does not authorize an update.
7. **Separate credentials by purpose.** PAT for API administration; SSH identity for Git transport; project config for preferences only.
8. **Preserve history.** Newly created GitHub repositories are empty (`auto_init=false`) so local history can be pushed without an automatically generated initial commit.
9. **Modular implementation.** Configuration, validation, Git inspection, API operations, and publishing have separate responsibilities.
10. **Project independence.** Each project can carry its own publishing preferences in `.github-publish.conf`.

## Evolution from specification to implementation

The former v2.0 document was a technical specification, not a description of a finished release. It proposed a `master`-only branch policy and assumed configuration was already present or could be omitted. The implemented v2.1 branch behavior supports both `main` and `master`, automatically selecting the current branch by default. Version 2.2 adds safe project-configuration initialization through an interactive prompt and `--init`.

This documentation describes the v2.2 implementation. Historical design statements are retained only when they explain why a safeguard or architectural choice exists; superseded proposals are not presented as current behavior.

## Intended use

Use GHPUtil when a local Git project is ready to publish to a GitHub repository owned by the authenticated account. It is not a general-purpose Git synchronization engine, merge tool, backup system, or replacement for normal Git review practices.
