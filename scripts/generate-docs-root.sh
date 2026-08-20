#!/usr/bin/env bash
#
# Patches the module tables into the top-level README.md, sourcing order/purpose from each module's own files.
# README.md is yours: every line is left untouched except the content between a <!-- generated:NAME:start -->
# / <!-- generated:NAME:end --> marker pair (see _replace_generated_blocks). There's no template and nothing
# gets rebuilt from scratch - README.md must already exist, with those markers placed wherever a table goes.
#
# Requires bash >= 4 (associative arrays) - macOS ships bash 3.2 as /bin/bash, use a newer one if needed (e.g.
# /opt/homebrew/bin/bash).
#
# Usage: scripts/generate-docs-root.sh [--no-fetch]
#   --no-fetch   skip badge downloads, reuse whatever's cached under images/ (not implemented yet). Icons are
#                never fetched at all - see ICON_DIR below.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration - the stuff a user is expected to tweak lives here.
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)"

MODULES_DIR="$REPO_ROOT/modules"
README_PATH="$REPO_ROOT/README.md"
IMAGES_DIR="$REPO_ROOT/images"

# Files checked, in this order, for a module's <!-- docs-meta: ... --> tag.
DOCS_META_CANDIDATES=("main.tf" "docker-compose.yml")

# Directory names walked into but never treated as a module themselves - template/asset dirs, not module code.
IGNORED_DIR_NAMES=("files")

# Zero-pad width for the order value before sorting (e.g. 010, 080). Orders are a flat, global scale (see
# walk_modules) - pick your own ranges, e.g. 010-070 for the main modules, 100-200 for docker-apps' children.
ORDER_WIDTH=3

# Icons live centrally here, one file per key (proxmox.svg, docker.svg, ...). A module opts in via icon=KEY in
# its docs-meta tag; KEY is looked up as ICON_DIR/KEY.svg then ICON_DIR/KEY.png. No fetching either way.
ICON_DIR="$IMAGES_DIR/icons"
ICON_DIR_REL="${ICON_DIR#"$REPO_ROOT"/}"   # repo-relative form, for README <img src>
ICON_EXTENSIONS=("svg" "png")

# Icons are rendered at a fixed width+height square, this many pixels.
ICON_MAX_SIZE=64

# ---------------------------------------------------------------------------
# Core functions: discover docs-meta tags, walk the module tree in apply
# order, and preserve hand-edited prose across regeneration.
# ---------------------------------------------------------------------------

# _trim STRING
# Strips leading/trailing whitespace via plain bash parameter expansion - not "echo ... | xargs", which
# shell-parses its input and chokes ("unterminated quote") on real prose containing backticks/quotes.
_trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# find_docs_meta DIR
# Prints the raw contents of DIR's docs-meta tag (everything after "docs-meta:", trimmed), or fails if neither
# candidate file has one. Expected fields: order=N (required), icon=KEY[,KEY...] (optional, comma-separated for
# multiple icons - e.g. a module running both Prometheus and Grafana Alloy - see ICON_DIR).
find_docs_meta() {
    local dir="$1" file raw
    for file in "${DOCS_META_CANDIDATES[@]}"; do
        [[ -f "$dir/$file" ]] || continue
        raw="$(grep -m1 'docs-meta:' "$dir/$file" 2>/dev/null || true)"
        [[ -n "$raw" ]] || continue
        raw="${raw#*docs-meta:}"
        raw="${raw%%-->*}"      # drop a trailing HTML comment close, if any
        raw="$(_trim "$raw")"
        [[ -n "$raw" ]] && printf '%s' "$raw" && return 0
    done
    return 1
}

# find_docs_purpose DIR
# Prints a one-line purpose for DIR: an explicit "docs-purpose:" comment in main.tf/docker-compose.yml if
# present, else the first prose paragraph under main.tf's "# Title" heading. Never README.md - it may itself be
# terraform-docs-generated, and shouldn't be a source for something terraform-docs doesn't know about. Empty
# output (not an error) if nothing usable is found.
find_docs_purpose() {
    local dir="$1" file raw purpose lines
    for file in "${DOCS_META_CANDIDATES[@]}"; do
        [[ -f "$dir/$file" ]] || continue
        raw="$(grep -m1 'docs-purpose:' "$dir/$file" 2>/dev/null || true)"
        if [[ -n "$raw" ]]; then
            raw="${raw#*docs-purpose:}"
            raw="${raw%%-->*}"
            printf '%s' "$(_trim "$raw")"
            return 0
        fi
    done
    if [[ -f "$dir/main.tf" ]]; then
        # Capture first, then feed via here-string - piping straight into _paragraph_after_heading (which
        # returns as soon as it's done, not after draining stdin) sends _clean_lines a SIGPIPE, and pipefail
        # turns that into a spurious pipeline failure even though the value would've been captured correctly.
        lines="$(_clean_lines "$dir/main.tf")"
        if purpose="$(_paragraph_after_heading <<<"$lines")"; then
            printf '%s' "$purpose"
            return 0
        fi
    fi
    return 1
}

# _clean_lines FILE
# Prints the lines between FILE's /** ... */ header comment as clean text - decoration and whitespace stripped,
# blank lines preserved. Only ever called on a main.tf; give any other file type its own reader, don't bolt a
# branch onto this one.
_clean_lines() {
    local file="$1" line trimmed in_comment=0
    while IFS= read -r line; do
        trimmed="$(_trim "$line")"
        if [[ "$in_comment" -eq 0 ]]; then
            [[ "$trimmed" == '/**' ]] && in_comment=1
            continue
        fi
        [[ "$trimmed" == '*/' ]] && return 0
        trimmed="${trimmed#\* }"
        trimmed="${trimmed#\*}"
        printf '%s\n' "$(_trim "$trimmed")"
    done < "$file"
}

# _title_from_lines
# Reads clean text lines from stdin (see _clean_lines), prints the first "# Heading" line's text.
_title_from_lines() {
    local line
    while IFS= read -r line; do
        if [[ "$line" == \#* ]]; then
            printf '%s' "$(_trim "${line#\#}")"
            return 0
        fi
    done
    return 1
}

# _paragraph_after_heading
# Reads clean text lines from stdin (see _clean_lines), prints the first paragraph after the first "# Heading" -
# lines joined with spaces until a blank line or the next heading ends it.
_paragraph_after_heading() {
    local line seen_title=0 result=""
    while IFS= read -r line; do
        if [[ "$seen_title" -eq 0 ]]; then
            [[ "$line" == \#* ]] && seen_title=1
            continue
        fi
        if [[ -z "$line" ]]; then
            [[ -n "$result" ]] && break
            continue
        fi
        [[ "$line" == \#* ]] && break
        if [[ -n "$result" ]]; then result+=" $line"; else result="$line"; fi
    done
    [[ -n "$result" ]] && printf '%s' "$result" && return 0
    return 1
}

# _module_title DIR
# An explicit "docs-title:" comment in main.tf/docker-compose.yml if present (a module with no main.tf has no
# "# Title" to scrape, so it needs somewhere to state one) - else the first "# Title" in main.tf's header
# comment - else the directory's own name.
_module_title() {
    local dir="$1" file raw title lines
    for file in "${DOCS_META_CANDIDATES[@]}"; do
        [[ -f "$dir/$file" ]] || continue
        raw="$(grep -m1 'docs-title:' "$dir/$file" 2>/dev/null || true)"
        if [[ -n "$raw" ]]; then
            raw="${raw#*docs-title:}"
            raw="${raw%%-->*}"
            printf '%s' "$(_trim "$raw")"
            return 0
        fi
    done
    if [[ -f "$dir/main.tf" ]]; then
        # See find_docs_purpose for why this is captured first rather than piped straight into _title_from_lines.
        lines="$(_clean_lines "$dir/main.tf")"
        if title="$(_title_from_lines <<<"$lines")"; then
            printf '%s' "$title"
            return 0
        fi
    fi
    basename -- "$dir"
}

# _parse_docs_meta_field TAG_CONTENTS KEY
# Extracts KEY=value out of a "order=10 icon=proxmox"-shaped string.
_parse_docs_meta_field() {
    local contents="$1" key="$2" token
    for token in $contents; do
        if [[ "$token" == "$key="* ]]; then
            printf '%s' "${token#*=}"
            return 0
        fi
    done
    return 1
}

# _is_listed NAME LIST_VAR_NAME
# True if NAME is one of the entries in the named array (e.g. IGNORED_DIR_NAMES).
_is_listed() {
    local needle="$1" list_name="$2" item
    local -n list_ref="$list_name"
    for item in "${list_ref[@]}"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# _is_gitignored DIR
# True if DIR is excluded by .gitignore - skips dead/generated dirs (e.g. the "Old service-configs" entries)
# entirely rather than just leaving them untagged. Falls back to "not ignored" if git isn't available.
_is_gitignored() {
    local dir="$1"
    command -v git >/dev/null 2>&1 || return 1
    git -C "$REPO_ROOT" check-ignore -q "$dir" 2>/dev/null
}

# walk_modules DIR [DEPTH]
# Recursively walks DIR, printing one tab-separated row per tagged directory found anywhere inside it:
#   order_padded <TAB> order <TAB> path <TAB> title <TAB> purpose <TAB> icon
#
# Order is a flat, global sort key (see ORDER_WIDTH) - no parent/child key concatenation. Every directory is
# walked into regardless of whether it carries a tag itself, so an untagged grouping folder (docker-apps,
# common) still surfaces its tagged children without producing a row of its own.
#
# At depth 0, a directory that's untagged with no tagged descendants goes into the unordered appendix ("~~~"
# sort key, sorts after every numeric one) instead of being dropped - it's either an oversight or just not
# ordered yet, as opposed to a deliberate grouping folder, which always has tagged children.
walk_modules() {
    local dir="$1" depth="${2:-0}"
    local entry name meta order icon icon_key title purpose rel_path order_padded
    local own_row child_rows all_rows=""

    [[ -d "$dir" ]] || return 0

    for entry in "$dir"/*/; do
        [[ -d "$entry" ]] || continue
        entry="${entry%/}"
        name="$(basename -- "$entry")"

        _is_listed "$name" IGNORED_DIR_NAMES && continue
        _is_gitignored "$entry" && continue

        own_row=""
        if meta="$(find_docs_meta "$entry")"; then
            order="$(_parse_docs_meta_field "$meta" order || echo 0)"
            icon_key="$(_parse_docs_meta_field "$meta" icon || true)"
            icon=""
            [[ -n "$icon_key" ]] && icon="$(_resolve_icons "$icon_key")"
            title="$(_module_title "$entry")"
            purpose="$(find_docs_purpose "$entry" || true)"
            rel_path="${entry#"$REPO_ROOT"/}"
            printf -v order_padded "%0${ORDER_WIDTH}d" "$order"
            own_row="$(printf '%s\t%s\t%s\t%s\t%s\t%s' \
                "$order_padded" "$order" "$rel_path" "$title" "$purpose" "$icon")"
        fi

        child_rows="$(walk_modules "$entry" $((depth + 1)))"

        [[ -n "$own_row" ]] && all_rows+="${own_row}"$'\n'
        [[ -n "$child_rows" ]] && all_rows+="${child_rows}"$'\n'

        if [[ "$depth" -eq 0 && -z "$own_row" && -z "$child_rows" ]]; then
            title="$(_module_title "$entry")"
            purpose="$(find_docs_purpose "$entry" || true)"
            rel_path="${entry#"$REPO_ROOT"/}"
            all_rows+="$(printf '~~~\t-\t%s\t%s\t%s\t' "$rel_path" "$title" "$purpose")"$'\n'
        fi
    done

    printf '%s' "$all_rows"
}

# _replace_generated_blocks FILE REPLACEMENTS_VAR
# Inverted from a "rebuild everything" template: FILE is yours by default, copied through untouched line for
# line. The only exception is content between a <!-- generated:NAME:start --> / <!-- generated:NAME:end -->
# pair, replaced with REPLACEMENTS_VAR[NAME] (marker lines themselves always kept). A NAME missing from
# REPLACEMENTS_VAR is left alone, old content included, so adding a new block doesn't touch the others. Writes
# FILE in place.
_replace_generated_blocks() {
    local file="$1" replacements_name="$2"
    local -n replacements_ref="$replacements_name"
    local line name="" in_block=0 out=""

    while IFS= read -r line; do
        if [[ "$in_block" -eq 0 && "$line" =~ \<!--\ generated:([A-Za-z0-9_-]+):start\ --\> ]]; then
            name="${BASH_REMATCH[1]}"
            out+="$line"$'\n'
            if [[ -n "${replacements_ref[$name]+set}" ]]; then
                out+="${replacements_ref[$name]}"
                in_block=1
            fi
            continue
        fi
        if [[ "$in_block" -eq 1 && "$line" == *"<!-- generated:${name}:end -->"* ]]; then
            out+="$line"$'\n'
            in_block=0
            name=""
            continue
        fi
        [[ "$in_block" -eq 1 ]] && continue   # old generated content, discarded
        out+="$line"$'\n'
    done < "$file"

    printf '%s' "$out" > "$file"
}

# _escape_table_cell TEXT
# Escapes "|" so TEXT is safe inside a GFM table cell - purpose text pulled from real prose can contain it.
_escape_table_cell() {
    printf '%s' "${1//|/\\|}"
}

# _render_table_row ORDER PATH TITLE PURPOSE ICON
# One GFM table row: icon cell if any, title linking to that module's own README, escaped purpose text.
_render_table_row() {
    local path="$2" title icon="$5" icon_cell=""
    title="$(_escape_table_cell "$3")"
    local purpose; purpose="$(_escape_table_cell "$4")"
    if [[ -n "$icon" ]]; then
        icon_cell="$(_icon_img_tag "$icon" "$title")"
    fi
    printf '| %s | [%s](%s/README.md) | %s |\n' "$icon_cell" "$title" "$path" "$purpose"
}

# render_readme
# Walks MODULES_DIR, computes the three module tables, and patches them into the existing README.md via
# _replace_generated_blocks - everything else in the file is left untouched. README.md must already exist with
# the three <!-- generated:*:start/end --> markers placed somewhere by hand; there's no template or seed text.
render_readme() {
    local table_header
    table_header="$(printf '| | Module | Purpose |\n|---|---|---|')"

    local order_key order path title purpose icon
    local top_rows="" app_rows="" appendix_rows="" row
    while IFS=$'\t' read -r order_key order path title purpose icon; do
        [[ -z "$order_key" ]] && continue
        # $(...) strips *all* trailing newlines, including the one _render_table_row printed - re-add it here
        # or every row ends up concatenated onto the same line with nothing between them.
        row="$(_render_table_row "$order" "$path" "$title" "$purpose" "$icon")"$'\n'
        if [[ "$order_key" == "~~~" ]]; then
            appendix_rows+="$row"
        elif [[ "$path" == modules/docker-apps/modules/* ]]; then
            app_rows+="$row"
        else
            top_rows+="$row"
        fi
    done < <(walk_modules "$MODULES_DIR" | sort -t $'\t' -k1,1 -k3,3)

    local -A generated=(
        [modules-table]="$table_header"$'\n'"$top_rows"
        [docker-apps-table]="$table_header"$'\n'"$app_rows"
        [appendix-table]="$table_header"$'\n'"$appendix_rows"
    )
    _replace_generated_blocks "$README_PATH" generated
}

# ---------------------------------------------------------------------------
# Icon/badge functions
# ---------------------------------------------------------------------------

# find_icon_by_key KEY
# Prints the repo-relative path to KEY's icon under ICON_DIR (first matching extension from ICON_EXTENSIONS),
# or fails if none exist. No fetching - icons are curated by hand. Relative, not absolute, because the only use
# is an <img src> in the generated README.
find_icon_by_key() {
    local key="$1" ext
    for ext in "${ICON_EXTENSIONS[@]}"; do
        [[ -f "$ICON_DIR/$key.$ext" ]] && printf '%s' "$ICON_DIR_REL/$key.$ext" && return 0
    done
    return 1
}

# _resolve_icons ICON_KEYS
# ICON_KEYS is a comma-separated list of keys (icon=KEY1,KEY2 in a docs-meta tag). Prints the resolved
# repo-relative paths, comma-joined, silently skipping any key with no matching file rather than failing the
# whole list over one bad key.
_resolve_icons() {
    local keys="$1" key path resolved=""
    local -a key_arr
    IFS=',' read -ra key_arr <<< "$keys"
    for key in "${key_arr[@]}"; do
        path="$(find_icon_by_key "$key" || true)"
        [[ -z "$path" ]] && continue
        if [[ -n "$resolved" ]]; then resolved+=",$path"; else resolved="$path"; fi
    done
    printf '%s' "$resolved"
}

# _icon_img_tag ICON_REL_PATHS ALT_TEXT
# Builds the <img> HTML for a module table cell - one <img> per comma-separated path (see _resolve_icons),
# each a fixed width+height square at ICON_MAX_SIZE, no dimension probing. Curated icons are expected to
# already be roughly square; a non-square one needs pre-cropping. Every image gets the same ALT_TEXT (the
# module's title) - good enough even for a multi-icon row, not worth distinguishing per-icon.
_icon_img_tag() {
    local icon_rel_list="$1" alt="${2//\"/&quot;}" icon_rel out=""
    [[ -z "$icon_rel_list" ]] && return 0
    local -a paths
    IFS=',' read -ra paths <<< "$icon_rel_list"
    for icon_rel in "${paths[@]}"; do
        out+="<img src=\"$icon_rel\" width=\"$ICON_MAX_SIZE\" height=\"$ICON_MAX_SIZE\" alt=\"$alt\"> "
    done
    printf '%s' "${out% }"
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

parse_args() {
    NO_FETCH=0
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-fetch) NO_FETCH=1; shift ;;
            -h|--help)
                grep -m14 '^#' "${BASH_SOURCE[0]}" | tail -n +2 | cut -c3-
                exit 0
                ;;
            *) echo "Unknown argument: $1" >&2; exit 1 ;;
        esac
    done
}

main() {
    parse_args "$@"
    render_readme
    echo "Wrote $README_PATH"
}

# Only run main if this script is executed directly, not sourced - lets the functions above be reused/tested
# from elsewhere.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
