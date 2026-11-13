# Function Call Graph

This module maps the actual function names in the GHPUtil v2.2 source package and the function-to-function calls found in those source files. It complements `015_program_flow.md`: that module explains the user-visible workflow, while this module exposes the implementation-level call structure.

## Scope and interpretation

- Nodes are functions actually defined in the packaged Bash source files.
- Solid arrows represent direct calls. Dashed arrows from `run_step()` represent dynamic dispatch: `main()` passes a function name to `run_step()`, which invokes that named function through `"$@"`.
- Subgraphs group functions by the source file in which they are defined.
- `install_main()` is shown as a separate installer entry point; it is not part of the normal publishing runtime.
- External commands such as `git`, `curl`, `ssh`, `sed`, `awk`, `cp`, and `chmod` are intentionally not shown as function nodes.

This is a static call graph, not a runtime trace. Conditional execution means an edge does not imply that the call happens on every invocation. Bash can also construct command names dynamically; the dispatcher targets shown here are the statically identifiable arguments passed by `main()`.

## Complete function call graph

The graph uses the same dark palette as the program-flow diagrams. Slate marks ordinary functions, teal marks entry and security-related functions, and purple marks orchestration. Cross-subgraph arrows are intentional: they represent calls between functions defined in different source files.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"background":"#0b1220","primaryColor":"#26364d","primaryTextColor":"#e6edf7","primaryBorderColor":"#7186a6","lineColor":"#8293ad","secondaryColor":"#1b2a40","tertiaryColor":"#172338","clusterBkg":"#172338","clusterBorder":"#526783","fontFamily":"Arial, sans-serif"}}}%%
flowchart TB
  subgraph I[install.sh]
    install_main([install_main()])
  end
  subgraph P[git_publish.sh]
    configure_origin_remote[configure_origin_remote()]
    verify_ssh_authentication[verify_ssh_authentication()]
    publish_branch[publish_branch()]
    verify_publication[verify_publication()]
    report_dry_run[report_dry_run()]
    report_success[report_success()]
  end
  subgraph A[github_api.sh]
    load_github_token[load_github_token()]
    cleanup_api_temp[cleanup_api_temp()]
    api_request[api_request()]
    github_authenticate[github_authenticate()]
    check_github_repository[check_github_repository()]
    github_create_repository[github_create_repository()]
    api_error_message[api_error_message()]
  end
  subgraph G[git_inspection.sh]
    inspect_local_repository[inspect_local_repository()]
    inspect_origin_remote[inspect_origin_remote()]
    remote_matches_intended_repository[remote_matches_intended_repository()]
  end
  subgraph V[validation.sh]
    die[die()]
    log[log()]
    run_step[run_step()]
    validate_enum[validate_enum()]
    resolve_project_root[resolve_project_root()]
    initialize_logging[initialize_logging()]
    validate_dependencies[validate_dependencies()]
  end
  subgraph C[config.sh]
    usage[usage()]
    parse_arguments[parse_arguments()]
    prepare_project_config[prepare_project_config()]
    load_project_config[load_project_config()]
    resolve_effective_config[resolve_effective_config()]
    resolve_visibility[resolve_visibility()]
    confirm_repository_creation[confirm_repository_creation()]
  end
  subgraph M[github_publish.sh]
    bootstrap([bootstrap()])
    main([main()])
  end

  bootstrap -->|direct call| main
  main -->|dispatches through run_step| run_step
  run_step -.->|dynamic target| parse_arguments
  run_step -.->|dynamic target| resolve_project_root
  run_step -.->|dynamic target| initialize_logging
  run_step -.->|dynamic target| prepare_project_config
  run_step -.->|dynamic target| load_project_config
  run_step -.->|dynamic target| resolve_effective_config
  run_step -.->|dynamic target| validate_dependencies
  run_step -.->|dynamic target| inspect_local_repository
  run_step -.->|dynamic target| load_github_token
  run_step -.->|dynamic target| github_authenticate
  run_step -.->|dynamic target| inspect_origin_remote
  run_step -.->|dynamic target| check_github_repository
  run_step -.->|dynamic target| resolve_visibility
  run_step -.->|dynamic target| confirm_repository_creation
  run_step -.->|dynamic target| github_create_repository
  run_step -.->|dynamic target| configure_origin_remote
  run_step -.->|dynamic target| verify_ssh_authentication
  run_step -.->|dynamic target| publish_branch
  run_step -.->|dynamic target| verify_publication
  run_step -->|on failure| cleanup_api_temp

  main -->|direct call| usage
  main -->|direct call| log
  main -->|direct call| report_dry_run
  main -->|direct call| report_success
  main -->|direct call| cleanup_api_temp
  main -->|error path| die

  parse_arguments --> die
  prepare_project_config --> die
  prepare_project_config --> log
  load_project_config --> die
  load_project_config --> log
  resolve_effective_config --> validate_enum
  resolve_effective_config --> die
  resolve_effective_config --> log
  resolve_visibility --> validate_enum
  resolve_visibility --> die
  resolve_visibility --> log
  confirm_repository_creation --> die
  confirm_repository_creation --> log

  die --> log
  validate_enum --> die
  resolve_project_root --> die
  initialize_logging --> die
  validate_dependencies --> die

  inspect_local_repository --> die
  inspect_local_repository --> log
  inspect_origin_remote --> remote_matches_intended_repository
  inspect_origin_remote --> die
  inspect_origin_remote --> log

  load_github_token --> die
  api_request --> die
  github_authenticate --> api_request
  github_authenticate --> die
  check_github_repository --> api_request
  check_github_repository --> api_error_message
  check_github_repository --> die
  github_create_repository --> api_request
  github_create_repository --> api_error_message
  github_create_repository --> die
  github_create_repository --> log

  configure_origin_remote --> die
  configure_origin_remote --> log
  verify_ssh_authentication --> die
  verify_ssh_authentication --> log
  publish_branch --> die
  publish_branch --> log
  verify_publication --> die
  verify_publication --> log
  report_dry_run --> log
  report_success --> log

  classDef ordinary fill:#26364d,stroke:#7186a6,color:#e6edf7,stroke-width:1px;
  classDef entry fill:#17434a,stroke:#4e9b9c,color:#e2ffff,stroke-width:2px;
  classDef security fill:#17434a,stroke:#4e9b9c,color:#e2ffff,stroke-width:1px;
  classDef orchestration fill:#40305c,stroke:#a78bd4,color:#f2eaff,stroke-width:2px;
  class bootstrap,main,install_main entry;
  class run_step,cleanup_api_temp orchestration;
  class load_github_token,api_request,github_authenticate,check_github_repository,github_create_repository,verify_ssh_authentication security;
  class configure_origin_remote,publish_branch,verify_publication,report_dry_run,report_success,api_error_message,inspect_local_repository,inspect_origin_remote,remote_matches_intended_repository,die,log,validate_enum,resolve_project_root,initialize_logging,validate_dependencies,usage,parse_arguments,prepare_project_config,load_project_config,resolve_effective_config,resolve_visibility,confirm_repository_creation ordinary;
  style I fill:#142238,stroke:#526783,stroke-width:1px,color:#e6edf7
  style P fill:#17263b,stroke:#526783,stroke-width:1px,color:#e6edf7
  style A fill:#18283d,stroke:#526783,stroke-width:1px,color:#e6edf7
  style G fill:#142238,stroke:#526783,stroke-width:1px,color:#e6edf7
  style V fill:#18283d,stroke:#526783,stroke-width:1px,color:#e6edf7
  style C fill:#142238,stroke:#526783,stroke-width:1px,color:#e6edf7
  style M fill:#1c2b42,stroke:#526783,stroke-width:1px,color:#e6edf7
```

## How to read the graph

1. The top-level `github_publish.sh` script invokes `bootstrap()`.
2. `bootstrap()` sources the utility modules and calls `main()`.
3. `main()` uses `run_step()` for most workflow functions so failures can be handled consistently.
4. `run_step()` invokes the function whose name it receives as an argument. Dashed arrows identify these dynamic dispatch targets; they are not hard-coded calls to every target inside `run_step()`.
5. `run_step()` calls `cleanup_api_temp()` when a dispatched operation fails. `main()` also calls cleanup on explicit repository-policy and completion paths.

`die()` delegates message output to `log()`. Many functions call `die()` on an error path and `log()` on normal or diagnostic paths. These shared services naturally create many cross-module arrows.

`install_main()` is invoked by the top-level `install.sh` script. It copies the runtime scripts and configuration template into the installation directory. It does not call `bootstrap()` or `main()`, so it is a separate entry point.

## Important limits

The graph records function relationships visible through static inspection of the packaged source. It does not claim every edge executes on every run, and it does not show external commands as Bash functions. If the implementation introduces indirect callbacks, `eval`, dynamically assembled function names, or additional sourced modules, regenerate and review this graph against the source. Source code remains authoritative; this document is a derived map.
