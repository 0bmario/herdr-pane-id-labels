#!/bin/sh
# Label every pane with its current pane ID. Only touches panes whose label is
# empty or already looks like a pane ID (wX:pY), so manual names are kept.
set -eu
h="${HERDR_BIN_PATH:-herdr}"
command -v jq >/dev/null 2>&1 || { echo "pane-id-labels: jq not found on PATH" >&2; exit 1; }
"$h" workspace list | jq -r '.result.workspaces[].workspace_id' | while read -r ws; do
  "$h" pane list --workspace "$ws" | jq -r '
    .result.panes[]
    | select(.label != .pane_id)
    | select((.label // "") == "" or (.label | test("^w[0-9A-Z]+:p[0-9A-Z]+$")))
    | .pane_id'
done | while read -r id; do
  "$h" pane rename "$id" "$id" >/dev/null
done
