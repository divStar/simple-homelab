#!/bin/bash
# Adds missing group permissions on share paths (dirs: g+rwxs, files: g+rw). Never removes bits or changes owners.
# Paths come from /etc/share-permissions.paths, excluded subtrees from /etc/share-permissions.excludes (one per line).
# Only prints what it changed ("<type> <old mode> <path>"), so the journal stays quiet when nothing was wrong.
# If TEXTFILE_DIRECTORY is set, per-share counts and the last run timestamp go to node_exporter's textfile collector.
set -euo pipefail

mapfile -t paths < <(grep -v '^[[:space:]]*$' /etc/share-permissions.paths)
mapfile -t excludes < <(grep -v '^[[:space:]]*$' /etc/share-permissions.excludes 2>/dev/null || true)

prune=()
for e in "${excludes[@]}"; do
  prune+=(-path "$e" -prune -o)
done

metrics=()
for p in "${paths[@]}"; do
  if [ ! -d "$p" ]; then
    echo "skipping missing path: $p"
    continue
  fi

  changed=$(find "$p" "${prune[@]}" \
    \( -type d ! -perm -2070 -printf '%y %m %p\n' -exec chmod g+rwxs {} + \) -o \
    \( -type f ! -perm -0060 -printf '%y %m %p\n' -exec chmod g+rw {} + \))

  dirs=$(grep -c '^d ' <<< "$changed" || true)
  files=$(grep -c '^f ' <<< "$changed" || true)
  if [ -n "$changed" ]; then
    echo "$p: fixed $dirs dirs, $files files"
    echo "$changed"
  fi

  label=${p//\\/\\\\}
  label=${label//\"/\\\"}
  metrics+=("share_permissions_fixed_entries{path=\"$label\",type=\"dir\"} $dirs")
  metrics+=("share_permissions_fixed_entries{path=\"$label\",type=\"file\"} $files")
done

if [ -n "${TEXTFILE_DIRECTORY:-}" ]; then
  # Written to a temp file first and renamed, so node_exporter never reads a half-written file
  prom="$TEXTFILE_DIRECTORY/share_permissions.prom"
  mkdir -p "$TEXTFILE_DIRECTORY"
  {
    echo "# HELP share_permissions_fixed_entries Entries whose group permissions were repaired in the last run"
    echo "# TYPE share_permissions_fixed_entries gauge"
    printf '%s\n' "${metrics[@]}"
    echo "# HELP share_permissions_last_run_timestamp_seconds Unix time the last run finished"
    echo "# TYPE share_permissions_last_run_timestamp_seconds gauge"
    echo "share_permissions_last_run_timestamp_seconds $(date +%s)"
  } > "$prom.$$"
  mv "$prom.$$" "$prom"
fi
