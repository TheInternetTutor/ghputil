# Program Flow and Execution Map

This document presents GHPUtil's end-to-end execution path before the detailed component documentation. The diagrams are intentionally split into landscape-oriented stages so the reader can follow the program without navigating one extremely tall flowchart.

The diagrams use compact left-to-right stage groups, with the work inside each stage arranged vertically where practical. This favors a landscape presentation close to the requested 16:9 shape; Mermaid renderers control the final pixel dimensions, so the exact aspect ratio depends on the viewing platform. The labels between diagrams identify the information handed from one stage to the next; they are conceptual continuation labels, not additional program operations.

## Stage A — Startup and project configuration

This stage resolves the installed utility, parses the command line, locates the project, and prepares its project-specific configuration. The `--help` and `--init` options can end execution before the publishing workflow begins.

```mermaid
flowchart LR
  subgraph A[Invocation and bootstrap]
    direction TB
    A1[Source github_publish.sh] --> A2[Resolve script directory]
    A2 --> A3[Load utility modules]
    A3 --> A4[Parse command-line arguments]
    A4 --> A5{Help requested?}
    A5 -- Yes --> A6[Display help and return]
    A5 -- No --> A7[Resolve project root]
    A7 --> A8[Initialize project logging]
  end
  subgraph B[Project configuration]
    direction TB
    B1[Locate .github-publish.conf] --> B2{Configuration exists?}
    B2 -- Yes --> B8{--init only?}
    B2 -- No --> B3{Interactive run or --init?}
    B3 -- Interactive --> B4[Ask to create from template]
    B3 -->|--init| B6[Create configuration from template]
    B3 -- Non-interactive --> BX[Stop and explain how to initialize]
    B4 --> B7{Accepted?}
    B7 -- Yes --> B6
    B7 -- No --> BX[Cancel and return]
    B6 --> B8
    B8 -- Yes --> BY[Return without publishing]
    B8 -- No --> B5[Load configuration]
    B5 --> B9[Resolve effective settings and CLI overrides]
  end
  A8 -->|Project root and log ready| B1
```

**Handoff to Stage B:** a resolved project root, initialized log, and effective project settings. If help is requested, initialization is complete, or configuration creation is declined, the workflow returns without publishing.

## Stage B — Local validation and GitHub repository decision

This stage verifies the local project and identifies the target GitHub account and repository. It then decides whether the remote repository must be created or whether the existing-repository policy requires stopping.

```mermaid
flowchart LR
  subgraph C[Local project checks]
    direction TB
    C1[Validate dependencies] --> C2[Inspect local Git repository]
    C2 --> C3[Resolve supported branch and local HEAD]
    C3 --> C4[Inspect identity and working-tree status]
  end
  subgraph D[GitHub API checks]
    direction TB
    D1[Read PAT securely] --> D2[Authenticate through HTTPS API]
    D2 --> D3[Identify GitHub account]
    D3 --> D4[Inspect origin and check target repository]
  end
  subgraph E[Repository decision]
    direction TB
    E1{Repository exists?}
    E1 -- No --> E2[Resolve visibility]
    E2 --> E3[Obtain creation authorization]
    E3 --> E4{Dry run?}
    E4 -- No --> E5[Create empty GitHub repository]
    E4 -- Yes --> E6[Record planned creation only]
    E1 -- Yes --> E7{Existing policy = update?}
    E7 -- No --> E8[Stop without pushing]
    E7 -- Yes --> E9[Continue to remote checks]
  end
  C4 -->|Validated local project| D1
  D4 --> E1
```

**Handoff to Stage C:** authenticated GitHub account, repository identity, resolved repository-existence policy, and—when needed—an empty remote repository. A normal run stops if an existing repository is governed by the default `stop` policy.

## Stage C — SSH, branch safety, publication, and verification

Repository administration uses HTTPS and the PAT; Git transport uses SSH. Before a push, GHPUtil verifies the intended `origin`, confirms SSH authentication, and inspects the remote branch. It only performs a normal push when the history relationship is safe.

```mermaid
flowchart LR
  subgraph F[Remote preparation]
    direction TB
    F1[Apply origin policy: add if missing, reuse if matching] --> F1A{Origin is safe to use?}
    F1A -- No --> FSTOP[Stop; never replace unrelated origin]
    F1A -- Yes --> F2[Add if missing, otherwise reuse matching origin]
    F2 --> F3{Dry run?}
    F3 -- Yes --> F4[Report planned actions; no push]
    F3 -- No --> F5[Inspect remote target branch]
  end
  subgraph G[Branch safety]
    direction TB
    G1{Remote branch exists?}
    G1 -- No --> G5[Normal push is eligible]
    G1 -- Yes --> G2{Remote commit equals local HEAD?}
    G2 -- Yes --> G3[No push needed]
    G2 -- No --> G4{Remote commit is ancestor of local HEAD?}
    G4 -- Yes --> G5
    G4 -- No --> G6[Refuse divergent or unrelated history]
  end
  subgraph H[Completion]
    direction TB
    H1[Push selected branch over SSH] --> H2{Post-push verification enabled?}
    H2 -- Yes --> H3[Compare remote commit with local HEAD]
    H2 -- No --> H4[Skip final comparison]
    H3 --> H5[Report result and clean temporary API files]
    H4 --> H5
    G3 --> H2
  end
  F2 -->|SSH ready| F3
  F5 --> G1
  G5 --> H1
```

**Terminal outcomes:** successful publication (with optional post-push verification), no push needed because the remote already matches local HEAD, dry-run report, or a safe refusal. GHPUtil does not force-push, merge, rewrite history, stage files, or create commits.

## Reading the component documentation

After following the overall flow, use the documentation index to move into the details of configuration, authentication, Git inspection, GitHub repository management, and publishing behavior. The diagrams describe the orchestration path; the individual modules define the rules and safeguards applied at each step.
