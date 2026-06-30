#!/bin/bash

# =========================================
# PlantUML Auto Builder (PNG + SVG)
# =========================================

# --- CONFIG ---
RECURSIVE=true
PLANTUML_CMD="plantuml"

# ποιότητα PNG
PLANTUML_LIMIT_SIZE=16384
SCALE=2

# output dir
OUT_DIR="./out"

# Προαιρετικό prefix τίτλου (override με env var)
TITLE_PREFIX="${TITLE_PREFIX:-LawerSystemControl}"

# Παράδειγμα title: LawerSystemControl - ver3 (version2) - 2026-04-17
build_diagram_title() {
    local file="$1"
    local base_name
    local version_dir
    local file_stem
    local build_date

    file_stem="$(basename "$file" .puml)"
    version_dir="$(basename "$(dirname "$file")")"
    base_name="${file_stem} (${version_dir})"
    build_date="$(date +%F)"

    echo "$TITLE_PREFIX - $base_name - $build_date"
}

# --- CHECK plantuml ---
if ! command -v "$PLANTUML_CMD" &> /dev/null; then
    echo "❌ plantuml not found. Install it with:"
    echo "   sudo apt install plantuml"
    exit 1
fi

mkdir -p "$OUT_DIR"

echo "🔍 Searching for .puml files..."

# --- FIND FILES (safe for spaces) ---
if [ "$RECURSIVE" = true ]; then
    mapfile -d '' FILES < <(find . -type f -name "*.puml" -print0)
else
    mapfile -d '' FILES < <(find . -maxdepth 1 -type f -name "*.puml" -print0)
fi

if [ ${#FILES[@]} -eq 0 ]; then
    echo "⚠️ No .puml files found."
    exit 0
fi

# --- PROCESS FILES ---
for file in "${FILES[@]}"; do
    echo "⚙️ Processing: $file"
    diagram_title="$(build_diagram_title "$file")"

    ABS_OUT=$(realpath "$OUT_DIR")

    # --- PNG ---
    "$PLANTUML_CMD" \
        -DPLANTUML_LIMIT_SIZE="$PLANTUML_LIMIT_SIZE" \
        "-DDIAGRAM_TITLE=$diagram_title" \
        -tpng \
        -S"$SCALE" \
        -o "$ABS_OUT" \
        "$file"

    # --- SVG ---
    "$PLANTUML_CMD" \
        -DPLANTUML_LIMIT_SIZE="$PLANTUML_LIMIT_SIZE" \
        "-DDIAGRAM_TITLE=$diagram_title" \
        -tsvg \
        -o "$ABS_OUT" \
        "$file"

    if [ $? -eq 0 ]; then
        echo "✅ Done: $file"
    else
        echo "❌ Failed: $file"
    fi
done

echo "🎉 All diagrams generated in: $OUT_DIR"
