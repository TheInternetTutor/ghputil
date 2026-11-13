# Function Call Graph — Rendering Alternatives

This module is the entry point for the three renderings of the implementation-level function call graph. They show the same source-derived relationships in different layouts. The split rendering is listed first because its smaller diagrams are the easiest to follow; the layered rendering is a compact single-graph alternative; the complete vertical rendering is available when a single comprehensive view is preferred.

## Available renderings

1. [Function Call Graph — Split](130_function_call_graph_split.md) — three focused diagrams covering entry-point orchestration, configuration and repository inspection, and API/publication. Recommended starting point for readability.
2. [Function Call Graph — Layered](140_function_call_graph_layered.md) — one graph grouped by execution responsibility, with a source-file key.
3. [Function Call Graph — Vertical](150_function_call_graph_vertical.md) — the complete graph arranged vertically. It retains all functions in one view and may require more scrolling.

## Parentheses in node labels

All three alternatives encode opening and closing parentheses in function labels as Mermaid numeric character entities: `#40;` and `#41;`. This avoids presenting raw parentheses to the flowchart parser while retaining familiar Bash function notation. If a renderer displays the entity text literally instead of decoding it, that renderer-specific result will be useful feedback; the labels can then be changed to omit parentheses.

## Shared interpretation

- Solid arrows represent direct calls.
- Dashed arrows represent dynamic dispatch targets passed by `main()` to `run_step()`.
- `install_main()` is a separate installer entry point, not part of the normal publishing runtime.
- These are static source-derived graphs, not runtime traces.
