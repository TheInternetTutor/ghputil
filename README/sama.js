/* Generated from ghputil_static_analysis.json. */
/* Load with a script tag; this defines window.MFCM_DATA. */
window.MFCM_DATA = {
  "project": "GHPUtil",
  "archive": "github_publish(16).zip",
  "analysis_method": "Static source inspection of the extracted Bash scripts. No scripts were executed. The function view is augmented with fictitious helper functions and recursive relationships distributed throughout the rows to stress-test visualization; these additions are not source-derived GHPUtil facts.",
  "module": {
    "rows": [
      "github_publish.sh",
      "config.sh",
      "validation.sh",
      "git_inspection.sh",
      "github_api.sh",
      "git_publish.sh",
      "install.sh",
      "github-publish.conf.example",
      ".github-publish.conf"
    ],
    "calls": [
      {
        "from": 0,
        "to": 1,
        "line_type": "solid"
      },
      {
        "from": 0,
        "to": 2,
        "line_type": "solid"
      },
      {
        "from": 0,
        "to": 3,
        "line_type": "solid"
      },
      {
        "from": 0,
        "to": 4,
        "line_type": "solid"
      },
      {
        "from": 0,
        "to": 5,
        "line_type": "solid"
      },
      {
        "from": 1,
        "to": 7,
        "line_type": "dashed"
      },
      {
        "from": 1,
        "to": 8,
        "line_type": "dashed"
      },
      {
        "from": 6,
        "to": 0,
        "line_type": "dashed"
      },
      {
        "from": 6,
        "to": 1,
        "line_type": "dashed"
      },
      {
        "from": 6,
        "to": 2,
        "line_type": "dashed"
      },
      {
        "from": 6,
        "to": 3,
        "line_type": "dashed"
      },
      {
        "from": 6,
        "to": 4,
        "line_type": "dashed"
      },
      {
        "from": 6,
        "to": 5,
        "line_type": "dashed"
      },
      {
        "from": 6,
        "to": 7,
        "line_type": "dashed"
      }
    ]
  },
  "function": {
    "rows": [
      {
        "name": "bootstrap()",
        "module": "github_publish.sh"
      },
      {
        "name": "scan_dependency_tree()",
        "module": "demo_graph_walk.sh"
      },
      {
        "name": "main()",
        "module": "github_publish.sh"
      },
      {
        "name": "usage()",
        "module": "config.sh"
      },
      {
        "name": "normalize_call_target()",
        "module": "demo_normalize.sh"
      },
      {
        "name": "parse_arguments()",
        "module": "config.sh"
      },
      {
        "name": "prepare_project_config()",
        "module": "config.sh"
      },
      {
        "name": "resolve_retry_policy()",
        "module": "demo_retry.sh"
      },
      {
        "name": "load_project_config()",
        "module": "config.sh"
      },
      {
        "name": "resolve_effective_config()",
        "module": "config.sh"
      },
      {
        "name": "walk_expression_nodes()",
        "module": "demo_expression.sh"
      },
      {
        "name": "resolve_visibility()",
        "module": "config.sh"
      },
      {
        "name": "confirm_repository_creation()",
        "module": "config.sh"
      },
      {
        "name": "visit_expression_node()",
        "module": "demo_expression.sh"
      },
      {
        "name": "die()",
        "module": "validation.sh"
      },
      {
        "name": "log_timestamp_style()",
        "module": "validation.sh"
      },
      {
        "name": "evaluate_guard_clause()",
        "module": "demo_expression.sh"
      },
      {
        "name": "log()",
        "module": "validation.sh"
      },
      {
        "name": "log_prompt()",
        "module": "validation.sh"
      },
      {
        "name": "reconcile_state()",
        "module": "demo_state.sh"
      },
      {
        "name": "run_step()",
        "module": "validation.sh"
      },
      {
        "name": "validate_enum()",
        "module": "validation.sh"
      },
      {
        "name": "refresh_dependency_cache()",
        "module": "demo_cache.sh"
      },
      {
        "name": "resolve_project_root()",
        "module": "validation.sh"
      },
      {
        "name": "initialize_logging()",
        "module": "validation.sh"
      },
      {
        "name": "dispatch_fallback()",
        "module": "demo_dispatch.sh"
      },
      {
        "name": "validate_dependencies()",
        "module": "validation.sh"
      },
      {
        "name": "inspect_local_repository()",
        "module": "git_inspection.sh"
      },
      {
        "name": "validate_nested_options()",
        "module": "demo_validation.sh"
      },
      {
        "name": "inspect_origin_remote()",
        "module": "git_inspection.sh"
      },
      {
        "name": "remote_matches_intended_repository()",
        "module": "git_inspection.sh"
      },
      {
        "name": "expand_reference_chain()",
        "module": "demo_reference.sh"
      },
      {
        "name": "load_github_token()",
        "module": "github_api.sh"
      },
      {
        "name": "cleanup_api_temp()",
        "module": "github_api.sh"
      },
      {
        "name": "resolve_alias_target()",
        "module": "demo_reference.sh"
      },
      {
        "name": "api_request()",
        "module": "github_api.sh"
      },
      {
        "name": "github_authenticate()",
        "module": "github_api.sh"
      },
      {
        "name": "finalize_operation()",
        "module": "demo_finalize.sh"
      },
      {
        "name": "check_github_repository()",
        "module": "github_api.sh"
      },
      {
        "name": "github_create_repository()",
        "module": "github_api.sh"
      },
      {
        "name": "recover_partial_state()",
        "module": "demo_recovery.sh"
      },
      {
        "name": "api_error_message()",
        "module": "github_api.sh"
      },
      {
        "name": "configure_origin_remote()",
        "module": "git_publish.sh"
      },
      {
        "name": "release_pending_resources()",
        "module": "demo_cleanup.sh"
      },
      {
        "name": "verify_ssh_authentication()",
        "module": "git_publish.sh"
      },
      {
        "name": "publish_branch()",
        "module": "git_publish.sh"
      },
      {
        "name": "summarize_execution()",
        "module": "demo_reporting.sh"
      },
      {
        "name": "verify_publication()",
        "module": "git_publish.sh"
      },
      {
        "name": "report_dry_run()",
        "module": "git_publish.sh"
      },
      {
        "name": "emit_completion_event()",
        "module": "demo_reporting.sh"
      },
      {
        "name": "report_success()",
        "module": "git_publish.sh"
      },
      {
        "name": "install_main()",
        "module": "install.sh"
      },
      {
        "name": "cleanup_deferred_items()",
        "module": "demo_cleanup.sh"
      }
    ],
    "calls": [
      {
        "from": 0,
        "to": 2,
        "line_type": "solid"
      },
      {
        "from": 1,
        "to": 1,
        "line_type": "recursive"
      },
      {
        "from": 2,
        "to": 20,
        "line_type": "solid"
      },
      {
        "from": 2,
        "to": 5,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 23,
        "line_type": "dashed"
      },
      {
        "from": 4,
        "to": 13,
        "line_type": "recursive"
      },
      {
        "from": 2,
        "to": 24,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 6,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 8,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 9,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 26,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 27,
        "line_type": "dashed"
      },
      {
        "from": 13,
        "to": 4,
        "line_type": "recursive"
      },
      {
        "from": 2,
        "to": 32,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 36,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 29,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 38,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 11,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 12,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 39,
        "line_type": "dashed"
      },
      {
        "from": 19,
        "to": 19,
        "line_type": "conditional_recursive"
      },
      {
        "from": 2,
        "to": 42,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 44,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 45,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 47,
        "line_type": "dashed"
      },
      {
        "from": 2,
        "to": 3,
        "line_type": "solid"
      },
      {
        "from": 2,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 2,
        "to": 48,
        "line_type": "solid"
      },
      {
        "from": 2,
        "to": 50,
        "line_type": "solid"
      },
      {
        "from": 22,
        "to": 40,
        "line_type": "conditional_recursive"
      },
      {
        "from": 2,
        "to": 33,
        "line_type": "solid"
      },
      {
        "from": 2,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 20,
        "to": 33,
        "line_type": "dashed"
      },
      {
        "from": 6,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 6,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 6,
        "to": 18,
        "line_type": "solid"
      },
      {
        "from": 8,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 8,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 40,
        "to": 22,
        "line_type": "conditional_recursive"
      },
      {
        "from": 9,
        "to": 21,
        "line_type": "solid"
      },
      {
        "from": 9,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 9,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 11,
        "to": 21,
        "line_type": "solid"
      },
      {
        "from": 11,
        "to": 18,
        "line_type": "solid"
      },
      {
        "from": 12,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 12,
        "to": 18,
        "line_type": "solid"
      },
      {
        "from": 14,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 28,
        "to": 49,
        "line_type": "recursive"
      },
      {
        "from": 17,
        "to": 15,
        "line_type": "solid"
      },
      {
        "from": 5,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 21,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 23,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 24,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 26,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 27,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 27,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 49,
        "to": 28,
        "line_type": "recursive"
      },
      {
        "from": 29,
        "to": 30,
        "line_type": "solid"
      },
      {
        "from": 29,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 29,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 32,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 35,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 36,
        "to": 35,
        "line_type": "solid"
      },
      {
        "from": 36,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 38,
        "to": 35,
        "line_type": "solid"
      },
      {
        "from": 38,
        "to": 41,
        "line_type": "solid"
      },
      {
        "from": 37,
        "to": 37,
        "line_type": "recursive"
      },
      {
        "from": 38,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 39,
        "to": 35,
        "line_type": "solid"
      },
      {
        "from": 39,
        "to": 41,
        "line_type": "solid"
      },
      {
        "from": 39,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 39,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 42,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 42,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 44,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 44,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 52,
        "to": 52,
        "line_type": "conditional_recursive"
      },
      {
        "from": 45,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 45,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 47,
        "to": 14,
        "line_type": "solid"
      },
      {
        "from": 47,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 48,
        "to": 17,
        "line_type": "solid"
      },
      {
        "from": 50,
        "to": 17,
        "line_type": "solid"
      }
    ]
  },
  "notes": [
    "github_publish.sh is the normal runtime entry point and sources five implementation modules.",
    "install.sh is a separate installer entry point; it copies six shell scripts and the configuration template.",
    "config.sh reads github-publish.conf.example when initializing a project and reads the project .github-publish.conf at runtime.",
    "The project configuration is data, not a sourced Bash module.",
    "run_step invokes function names passed to it by main; the targets are represented as dashed dispatch edges.",
    "Functions with no identified user-defined caller remain in the diagram; this does not prove they are unused.",
    "Calls into Bash builtins, external commands, and operating-system utilities are excluded from the function-to-function graph.",
    "The function diagram includes 10 synthetic recursion relationships, interleaved among ordinary calls and distributed from near the beginning to near the end, solely to demonstrate visualization behavior; these are not source-derived GHPUtil facts."
  ]
};
