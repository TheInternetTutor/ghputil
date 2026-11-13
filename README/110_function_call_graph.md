# Function Call Graph — Rendering Alternatives

The original all-in-one rendering has been replaced here by a short guide to three alternatives. Each alternative documents the same implementation-level relationships, but uses a different layout. Compare the pages and choose the one that is easiest to read in your Mermaid viewer.

- [`111_function_call_graph_vertical.md`](111_function_call_graph_vertical.md) — complete graph, arranged vertically.
- [`112_function_call_graph_split.md`](112_function_call_graph_split.md) — three focused diagrams that divide the graph into manageable sections.
- [`113_function_call_graph_layered.md`](113_function_call_graph_layered.md) — grouped by execution responsibility rather than source-file order.

## Parentheses in node labels

All three alternatives encode the opening and closing parentheses in function labels as Mermaid numeric character entities: `#40;` and `#41;`. This avoids presenting raw parentheses to the flowchart parser while retaining the familiar Bash function notation. If a renderer displays the entity text literally instead of decoding it, that renderer-specific result will be useful feedback; the labels can then be changed to omit parentheses.

## Shared interpretation

- Solid arrows represent direct calls.
- Dashed arrows represent dynamic dispatch targets passed by `main()` to `run_step()`.
- `install_main()` is a separate installer entry point, not part of the normal publishing runtime.
- These are static source-derived graphs, not runtime traces.
