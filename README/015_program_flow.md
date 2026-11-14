# Program Flow and Execution Map

This document presents GHPUtil's end-to-end execution path before the detailed component documentation. The diagrams use the empirically preferred Mermaid layout: the parent flowchart and each subgraph use `TB`, while subgraphs are declared in reverse order so the rendered groups appear in the intended left-to-right sequence. Steps inside each group are stacked vertically.

## Visual conventions

- **Stadium-shaped nodes** mark the entry to a subgraph or a terminal outcome.
- **Double-edged subroutine nodes** mark an explicit handoff to the next subgraph or flowchart. They are real nodes inside the preceding subgraph, not captions or external notes.
- **Diamonds** represent decisions.
- **Rounded process nodes** represent actions; colors distinguish ordinary processing, decisions, security/transport operations, and handoffs.
- No arrows are drawn between subgraphs. The handoff is made explicit by a final node in the current subgraph and a matching entry node in the next subgraph.

The diagrams use Mermaid's `base` theme with a coordinated dark palette. Colors are semantic and intentionally muted for readability.

## Stage A — Startup and project configuration

This stage resolves the installed utility, parses the command line, locates the project, and prepares its project-specific configuration. The `--help` and `--init` options can end execution before the publishing workflow begins.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"background":"#0b1220","primaryColor":"#26364d","primaryTextColor":"#e6edf7","primaryBorderColor":"#7186a6","lineColor":"#8293ad","secondaryColor":"#1b2a40","tertiaryColor":"#172338","clusterBkg":"#172338","clusterBorder":"#526783","fontFamily":"Arial, sans-serif"}}}%%
flowchart TB
  subgraph B[Project configuration]
    direction TB
    B0([ENTRY: Project configuration])
    B0 --> B1[Locate .github-publish.conf]
    B1 --> B2{Configuration exists?}
    B2 -- Yes --> B8{--init only?}
    B2 -- No --> B3{Interactive run or --init?}
    B3 -- Interactive --> B4[Ask to create from template]
    B3 --> |--init| B6[Create configuration from template]
    B3 -- Non-interactive --> BX([STOP: Explain initialization options])
    B4 --> B7{Accepted?}
    B7 -- Yes --> B6
    B7 -- No --> BY([STOP: User declined configuration creation])
    B6 --> B8
    B8 -- Yes --> BZ([END: Configuration initialized; no publishing])
    B8 -- No --> B5[Load configuration]
    B5 --> B9[Resolve effective settings and CLI overrides]
    B9 --> B10[[NEXT FLOWCHART: Stage B — Local project checks]]
  end
  subgraph A[Invocation and bootstrap]
    direction TB
    A0([ENTRY: Utility invocation])
    A0 --> A1[Source github_publish.sh]
    A1 --> A2[Resolve script directory]
    A2 --> A3[Load utility modules]
    A3 --> A4[Parse command-line arguments]
    A4 --> A5{Help requested?}
    A5 -- Yes --> A6([END: Display help and return])
    A5 -- No --> A7[Resolve project root]
    A7 --> A8[Initialize project logging]
    A8 --> A9[[NEXT SUBGRAPH: Project configuration]]
  end
  classDef process fill:#26364d,stroke:#7186a6,color:#e6edf7,stroke-width:1px;
  classDef decision fill:#554329,stroke:#c69b58,color:#fff1d6,stroke-width:1px;
  classDef secure fill:#17434a,stroke:#4e9b9c,color:#e2ffff,stroke-width:1px;
  classDef handoff fill:#40305c,stroke:#a78bd4,color:#f2eaff,stroke-width:2px;
  classDef endpoint fill:#17434a,stroke:#4e9b9c,color:#e2ffff,stroke-width:2px;
  class A0,A6,A7,A8,A1,A2,A3,A4,B1,B4,B6,B5,B9 process;
  class A5,B2,B3,B7,B8 decision;
  class A9,B10 handoff;
  class B0,BX,BY,BZ endpoint;
  style A fill:#142238,stroke:#526783,stroke-width:1px,color:#e6edf7
  style B fill:#18283d,stroke:#526783,stroke-width:1px,color:#e6edf7
```

**Execution sequence:** Invocation and bootstrap → Project configuration → Stage B's Local project checks. The `A9` handoff node names the next subgraph; `B0` marks its entry. After configuration is resolved, `B10` names the next flowchart and its first subgraph. Help, completed `--init`, declined configuration creation, or a non-interactive missing configuration can terminate the run without publishing.

## Stage B — Local validation and GitHub repository decision

This stage verifies the local project and identifies the target GitHub account and repository. Each group's checks proceed from top to bottom. The groups are declared in reverse order to produce the preferred visual order: Local project checks, GitHub API checks, then Repository decision.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"background":"#0b1220","primaryColor":"#26364d","primaryTextColor":"#e6edf7","primaryBorderColor":"#7186a6","lineColor":"#8293ad","secondaryColor":"#1b2a40","tertiaryColor":"#172338","clusterBkg":"#172338","clusterBorder":"#526783","fontFamily":"Arial, sans-serif"}}}%%
flowchart TB
  subgraph E[Repository decision]
    direction TB
    E0([ENTRY: Repository decision])
    E0 --> E1{Repository exists?}
    E1 -- No --> E2[Resolve visibility]
    E2 --> E3[Obtain creation authorization]
    E3 --> E4{Dry run?}
    E4 -- No --> E5[Create empty GitHub repository]
    E4 -- Yes --> E6[Record planned creation only]
    E5 --> E9[[NEXT FLOWCHART: Stage C — Remote preparation]]
    E6 --> E9
    E1 -- Yes --> E7{Existing policy = update?}
    E7 -- No --> E8([STOP: Existing-repository policy is stop])
    E7 -- Yes --> E9
  end
  subgraph D[GitHub API checks]
    direction TB
    D0([ENTRY: GitHub API checks])
    D0 --> D1[Read PAT securely]
    D1 --> D2[Authenticate through HTTPS API]
    D2 --> D3[Identify GitHub account]
    D3 --> D4[Inspect origin and check target repository]
    D4 --> D5[[NEXT SUBGRAPH: Repository decision]]
  end
  subgraph C[Local project checks]
    direction TB
    C0([ENTRY: Local project checks])
    C0 --> C1[Validate dependencies]
    C1 --> C2[Inspect local Git repository]
    C2 --> C3[Resolve supported branch and local HEAD]
    C3 --> C4[Inspect identity and working-tree status]
    C4 --> C5[[NEXT SUBGRAPH: GitHub API checks]]
  end
  classDef process fill:#26364d,stroke:#7186a6,color:#e6edf7,stroke-width:1px;
  classDef decision fill:#554329,stroke:#c69b58,color:#fff1d6,stroke-width:1px;
  classDef secure fill:#17434a,stroke:#4e9b9c,color:#e2ffff,stroke-width:1px;
  classDef handoff fill:#40305c,stroke:#a78bd4,color:#f2eaff,stroke-width:2px;
  classDef endpoint fill:#17434a,stroke:#4e9b9c,color:#e2ffff,stroke-width:2px;
  class C1,C2,C3,C4,E2,E3,E5,E6 process;
  class D1,D2,D3,D4 secure;
  class E1,E4,E7 decision;
  class C5,D5,E9 handoff;
  class C0,D0,E0,E8 endpoint;
  style C fill:#142238,stroke:#526783,stroke-width:1px,color:#e6edf7
  style D fill:#18283d,stroke:#526783,stroke-width:1px,color:#e6edf7
  style E fill:#1c2b42,stroke:#526783,stroke-width:1px,color:#e6edf7
```

**Execution sequence:** Stage A → Local project checks → GitHub API checks → Repository decision → Stage C's Remote preparation. `C5`, `D5`, and `E9` are explicit handoff nodes; the receiving subgraphs identify their entry points. The repository-decision branches either stop under the `stop` policy or continue to Stage C. A dry run records planned creation rather than creating the remote repository.

## Stage C — SSH, remote recovery, publication, and verification

Repository administration uses HTTPS and the PAT; Git transport uses SSH. Before a push, GHPUtil verifies the intended `origin`, confirms SSH authentication, and inspects the remote branch. It retrieves remote objects into a temporary ref before ancestry checks. If remote-only commits exist, it creates and verifies an incremental bundle, extracts only the remote-changed file versions into `GHPUtil-Remote/`, writes a manifest, deletes the bundle only after successful extraction, and stops for manual comparison. A normal push remains available when the remote is an ancestor of local HEAD. The groups are declared in reverse order to render as Remote preparation, Branch safety, and Completion.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"background":"#0b1220","primaryColor":"#26364d","primaryTextColor":"#e6edf7","primaryBorderColor":"#7186a6","lineColor":"#8293ad","secondaryColor":"#1b2a40","tertiaryColor":"#172338","clusterBkg":"#172338","clusterBorder":"#526783","fontFamily":"Arial, sans-serif"}}}%%
flowchart TB
  subgraph H[Completion]
    direction TB
    H0([ENTRY: Completion])
    H0 --> H1[Push selected branch over SSH when needed]
    H1 --> H2{Post-push verification enabled?}
    H2 -- Yes --> H3[Compare remote commit with local HEAD]
    H2 -- No --> H4[Skip final comparison]
    H3 --> H5[Report result and clean temporary API files]
    H4 --> H5
    H5 --> H6([END: Publishing workflow complete])
  end
  subgraph G[Branch safety]
    direction TB
    G0([ENTRY: Branch safety])
    G0 --> G1{Remote branch exists?}
    G1 -- No --> G5[Normal push is eligible]
    G1 -- Yes --> G2[Fetch remote commit into temporary ref]
    G2 --> G3{Remote equals local HEAD?}
    G3 -- Yes --> G7[[NEXT SUBGRAPH: Completion]]
    G3 -- No --> G4{Remote is ancestor of local HEAD?}
    G4 -- Yes --> G5
    G4 -- No --> G6[Create incremental bundle after common ancestor]
    G6 --> G8[Verify bundle and extract remote-changed files]
    G8 --> G9[Write manifest; delete bundle after verification]
    G9 --> G10([STOP: Ready for manual comparison and integration])
    G5 --> G7
  end
  subgraph F[Remote preparation]
    direction TB
    F0([ENTRY: Remote preparation])
    F0 --> F1[Evaluate origin policy]
    F1 --> F1A{Origin is safe to use?}
    F1A -- No --> FSTOP([STOP: Never replace unrelated origin])
    F1A -- Yes --> F2[Add missing origin or reuse matching origin]
    F2 --> F3{Dry run?}
    F3 -- Yes --> F4([END: Report planned actions; no push])
    F3 -- No --> F5[Confirm SSH authentication and inspect remote target branch]
    F5 --> F6[[NEXT SUBGRAPH: Branch safety]]
  end
  classDef process fill:#26364d,stroke:#7186a6,color:#e6edf7,stroke-width:1px;
  classDef decision fill:#554329,stroke:#c69b58,color:#fff1d6,stroke-width:1px;
  classDef secure fill:#17434a,stroke:#4e9b9c,color:#e2ffff,stroke-width:1px;
  classDef handoff fill:#40305c,stroke:#a78bd4,color:#f2eaff,stroke-width:2px;
  classDef endpoint fill:#17434a,stroke:#4e9b9c,color:#e2ffff,stroke-width:2px;
  class F1,F2,G2,G6,G8,G9,G5,H1,H3,H4,H5 process;
  class F5 secure;
  class F1A,F3,G1,G3,G4,H2 decision;
  class F6,G7 handoff;
  class F0,G0,H0,FSTOP,F4,G10,H6 endpoint;
  style F fill:#142238,stroke:#526783,stroke-width:1px,color:#e6edf7
  style G fill:#18283d,stroke:#526783,stroke-width:1px,color:#e6edf7
  style H fill:#1c2b42,stroke:#526783,stroke-width:1px,color:#e6edf7
```

**Execution sequence:** Stage B → Remote preparation → Branch safety → Completion. `F6` and `G7` explicitly identify the next subgraph, whose entry node is marked. The workflow ends at `H6`; the dry-run and safety-refusal branches terminate earlier. No inter-subgraph arrows are used.

**Terminal outcomes:** successful publication (with optional post-push verification), no push needed because the remote already matches local HEAD, remote recovery snapshot ready for manual integration, dry-run report, or a safe refusal. GHPUtil does not force-push, merge, rewrite history, stage files, or create commits.

## Reading the component documentation

After following the overall flow, use the documentation index to move into the details of configuration, authentication, Git inspection, GitHub repository management, and publishing behavior. The diagrams describe the orchestration path; the individual modules define the rules and safeguards applied at each step.
