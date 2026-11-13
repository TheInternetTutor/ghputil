# GHPUtil Documentation Index

This directory contains the detailed documentation for GHPUtil. The root [`README.md`](../README.md) is the practical quick-start guide; these modules explain the utility's design and behavior in depth.

## Modules

- [`010_purpose_and_design_principles.md`](010_purpose_and_design_principles.md) — Original problem, goals, conservative operating principles, and the evolution from specification to working utility.
- [`015_program_flow.md`](015_program_flow.md) — Dark-themed, landscape-oriented Mermaid diagrams with explicit in-subgraph handoff and receiving-entry nodes, showing startup, configuration, local validation, GitHub repository decisions, SSH setup, branch safety, publishing, and verification.
- [`020_architecture_and_operating_environment.md`](020_architecture_and_operating_environment.md) — Supported environment, component responsibilities, dependencies, and execution model.
- [`030_configuration_and_settings.md`](030_configuration_and_settings.md) — Project configuration, template initialization, supported keys, defaults, precedence, and validation.
- [`040_authentication_and_security.md`](040_authentication_and_security.md) — PAT storage and handling, GitHub API access, SSH transport, and credential separation.
- [`050_git_repository_and_branch_policies.md`](050_git_repository_and_branch_policies.md) — Local repository checks, author identity, committed-only publication, and `main`/`master` branch rules.
- [`060_github_repository_management.md`](060_github_repository_management.md) — Repository naming, discovery, creation, existing-repository policy, and remote safeguards.
- [`070_publishing_workflow.md`](070_publishing_workflow.md) — End-to-end execution sequence, dry-run behavior, push checks, verification, and reporting.
- [`080_command_line_reference.md`](080_command_line_reference.md) — Complete command-line syntax, options, combinations, and examples.
- [`090_installation_and_maintenance.md`](090_installation_and_maintenance.md) — Installation, sourcing, aliases, logs, permissions, upgrades, and operational checks.
- [`100_troubleshooting_and_limitations.md`](100_troubleshooting_and_limitations.md) — Common failure conditions, diagnostic guidance, known boundaries, and deferred capabilities.
- [`110_source_file_dependency_graph.md`](110_source_file_dependency_graph.md) — Package-level source, template, installer-copy, and project-configuration dependencies; first of the two graph modules.
- [`120_function_call_graph.md`](120_function_call_graph.md) — Function-call graph landing page, linking to the split, layered, and vertical renderings in that preferred order.

## Reading paths

- **First use:** root `README.md`, then the program-flow diagrams in module 015, followed by modules 030 and 040.
- **Understanding safety:** modules 050, 060, and 070.
- **Command or configuration lookup:** modules 030 and 080.
- **Installation or problem diagnosis:** modules 090 and 100.

## Version and historical context

The former v2.0 technical specification has been consolidated into these modules rather than retained as a separate competing README. Its original design intent is preserved where still relevant. Where the implemented v2.2 behavior differs from the v2.0 proposal, this documentation describes the implemented behavior and identifies the historical distinction where useful.
