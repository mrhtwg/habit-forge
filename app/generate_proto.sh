#!/bin/bash

###############################################################################
# HabitForge · Proto → Dart code generator
#
# Reference: tata_project/tata/generate_proto.sh (protoc + protoc-gen-dart + barrel)
#
# Source:   ../proto/                 # shared contracts (app + server)
#   ├── api/<service>/v1/*.proto
#   └── third_party/google/api/       # google.api.http annotations
#
# Output:   lib/generated/protos/<service>/v1/*.dart
#
# Usage:
#   ./generate_proto.sh              # generate all modules (messages only, REST mode)
#   ./generate_proto.sh --grpc       # also generate the gRPC client (add the grpc dep)
#   ./generate_proto.sh --clean      # remove the generated directory
#   ./generate_proto.sh --help       # show help
#
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROTOCOL_DIR="$SCRIPT_DIR/../proto"
DART_OUT_DIR="$SCRIPT_DIR/lib/generated/protos"

# ── Colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
  cat << EOF

Proto → Dart generator

Usage:
    ./generate_proto.sh [options]

Options:
    --grpc      also generate the gRPC client (.pbgrpc.dart); requires the grpc package
    --clean     remove the lib/generated/protos directory
    --help, -h  show this help

Examples:
    ./generate_proto.sh            # generate messages (REST/JSON mode, default)
    ./generate_proto.sh --grpc     # generate messages + gRPC client

EOF
  exit 0
}

check_tools() {
  if ! command -v protoc &> /dev/null; then
    error "protoc is not installed!"
    echo "  macOS: brew install protobuf"
    exit 1
  fi
  info "protoc version: $(protoc --version)"

  if ! command -v protoc-gen-dart &> /dev/null; then
    error "protoc-gen-dart is not installed!"
    echo "  flutter pub global activate protoc_plugin"
    echo "  export PATH=\"\$PATH\":\"\$HOME/.pub-cache/bin\""
    exit 1
  fi
  info "protoc-gen-dart installed"
}

clean() {
  info "Cleaning generated directory..."
  if [ -d "$DART_OUT_DIR" ]; then
    rm -rf "$DART_OUT_DIR"
    success "Removed: $DART_OUT_DIR"
  else
    warn "Directory does not exist: $DART_OUT_DIR"
  fi
  exit 0
}

# Generate barrel files (export all .pb.dart / .pbgrpc.dart in each module)
generate_barrels() {
  local count=0
  for module_dir in "$DART_OUT_DIR"/*; do
    [ -d "$module_dir" ] || continue
    for version_dir in "$module_dir"/*; do
      [ -d "$version_dir" ] || continue
      local module_name version pb_files=()
      module_name=$(basename "$module_dir")
      version=$(basename "$version_dir")
      while IFS= read -r -d '' f; do
        local base
        base=$(basename "$f")
        case "$base" in
          *.pb.dart)    [ "${base##*.pb.}" != "json" ] && [ "${base##*.pb.}" != "enum" ] && pb_files+=("$base") ;;
          *.pbgrpc.dart) pb_files+=("$base") ;;
        esac
      done < <(find "$version_dir" -maxdepth 1 -name "*.dart" -print0)
      if [ ${#pb_files[@]} -gt 0 ]; then
        local barrel="$version_dir/${module_name}.dart"
        {
          echo "// Auto-generated barrel file for $module_name/$version"
          echo "// Exports all protobuf generated files for simpler imports."
          echo ""
          for pb in "${pb_files[@]}"; do
            echo "export '$pb';"
          done
        } > "$barrel"
        count=$((count + 1))
        success "Created barrel: ${module_name}/${version}/${module_name}.dart"
      fi
    done
  done
  [ $count -gt 0 ] && info "Import via: import 'package:habit_forge_app/generated/protos/<svc>/v1/<svc>.dart';"
}

# ── Argument parsing ──
GRPC=0
case "$1" in
  --help|-h) show_help ;;
  --clean)   clean ;;
  --grpc)    GRPC=1 ;;
esac

check_tools

if [ ! -d "$PROTOCOL_DIR" ]; then
  error "Shared contract directory not found: $PROTOCOL_DIR"
  exit 1
fi

mkdir -p "$DART_OUT_DIR"

DART_OPT="$DART_OUT_DIR"
[ $GRPC -eq 1 ] && DART_OPT="grpc:$DART_OUT_DIR" && info "Enabling gRPC client generation"

info "Proto directory: $PROTOCOL_DIR"
info "Output directory: $DART_OUT_DIR"

# Generate: proto_path rooted at api/ (output has no api/ prefix); third_party
# provides the google.api annotations (compiled only, not generated into Dart)
protoc \
  --proto_path="$PROTOCOL_DIR/api" \
  --proto_path="$PROTOCOL_DIR/third_party" \
  --dart_out="$DART_OPT" \
  "$PROTOCOL_DIR"/api/*/v1/*.proto

generate_barrels

COUNT=$(find "$DART_OUT_DIR" -name "*.dart" | wc -l | tr -d ' ')
success "Done! Dart files: $COUNT"
