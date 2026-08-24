#!/bin/bash

# --- Script Configuration ---
# Make script exit on any command failure
set -e

# Enable nullglob to handle cases where glob doesn't match any files
shopt -s nullglob

# Function to print usage
print_usage() {
    echo "Usage:"
    echo "  $0 --env [environment] --build-name [name] --build-number [number] [--type apk|aab] [options]"
    echo ""
    echo "Parameter Description:"
    echo "  --env          Data storage mode: hive (local), firebase, or server."
    echo "  --build-name   Set the version name (e.g., 1.0.0)."
    echo "  --build-number Set the build number (used as version code)."
    echo "  --type         Output type: apk (default) or aab."
    echo "  --verbose      Enable verbose flutter build output."
    echo ""
}

# --- Argument Parsing ---
ENV=""
BUILD_NAME=""
BUILD_NUMBER=""
BUILD_TYPE="apk"  # Default build type: APK

# Optional environment config override arguments (use when --env does not meet the requirements)
VERBOSE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"
      shift # past argument
      shift # past value
      ;;
    --build-name)
      BUILD_NAME="$2"
      shift
      shift
      ;;
    --build-number)
      BUILD_NUMBER="$2"
      shift
      shift
      ;;
    --type)
      BUILD_TYPE="$2"
      shift
      shift
      ;;
    --verbose)
      VERBOSE="--verbose"
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      print_usage
      exit 1
      ;;
    *)
      echo "Unknown positional argument: $1"
      print_usage
      exit 1
      ;;
  esac
done

# --- Validation ---
if [[ -z "$ENV" ]]; then
    echo "Error: Missing --env parameter."
    print_usage
    exit 1
fi

if [[ -z "$BUILD_NUMBER" ]]; then
    echo "Error: Missing --build-number parameter."
    print_usage
    exit 1
fi

if [[ -z "$BUILD_NAME" ]]; then
    echo "Error: Missing --build-name parameter."
    print_usage
    exit 1
fi

if [[ "$BUILD_TYPE" != "apk" && "$BUILD_TYPE" != "aab" ]]; then
    echo "Error: Invalid --type value '$BUILD_TYPE'. Must be 'apk' or 'aab'."
    print_usage
    exit 1
fi

# --- Prerequisites Check ---
# Check if Flutter is installed and in PATH
if ! command -v flutter &> /dev/null
then
    echo "Error: Flutter is not installed or not added to the system PATH. Please check your setup!"
    exit 1
fi

# Check if the current directory is a Flutter project (basic check)
if [[ ! -f "pubspec.yaml" ]]; then
    echo "Error: The current directory does not appear to be a Flutter project root (missing pubspec.yaml). Please navigate to the correct directory and try again!"
    exit 1
fi

# --- Build Process ---

# Get current timestamp (more precise than just date/time)
CURRENT_DATETIME=$(date +"%Y-%m-%d_%H-%M-%S")

# Define filenames and paths based on build type
if [[ "$BUILD_TYPE" == "aab" ]]; then
    OUTPUT_FILE_NAME="habitforge_${ENV}_${BUILD_NAME}_${CURRENT_DATETIME}.aab"
    SOURCE_OUTPUT_PATH="build/app/outputs/bundle/release/app-release.aab"
    TARGET_OUTPUT_DIR="../apks/${ENV}"
    TARGET_OUTPUT_PATH="${TARGET_OUTPUT_DIR}/${OUTPUT_FILE_NAME}"
else
    OUTPUT_FILE_NAME="habitforge_${ENV}_${BUILD_NAME}_${CURRENT_DATETIME}.apk"
    SOURCE_OUTPUT_PATH="build/app/outputs/flutter-apk/app-release.apk"
    TARGET_OUTPUT_DIR="../apks/${ENV}"
    TARGET_OUTPUT_PATH="${TARGET_OUTPUT_DIR}/${OUTPUT_FILE_NAME}"
fi

echo "Starting Android $(echo "$BUILD_TYPE" | tr '[:lower:]' '[:upper:]') build process..."
echo "Environment: $ENV"
echo "Build Name: $BUILD_NAME"
echo "Build Number: $BUILD_NUMBER"
echo "Build Type: $BUILD_TYPE"
echo "Verbose: $(if [[ -n "$VERBOSE" ]]; then echo "yes"; else echo "no"; fi)"
echo "Target File: $OUTPUT_FILE_NAME"
echo "----------------------------------------"

# Validate environment (data storage mode)
if [[ "$ENV" != "hive" && "$ENV" != "firebase" && "$ENV" != "server" ]]; then
    echo "Error: Unknown environment '$ENV'. Must be 'hive', 'firebase' or 'server'."
    exit 1
fi

# Run the flutter build command matching the build type
if [[ "$BUILD_TYPE" == "aab" ]]; then
    echo "Building AAB..."
    flutter build appbundle --release \
      $VERBOSE \
      --obfuscate --split-debug-info=build/debug-info \
      --dart-define-from-file=env/$ENV.json \
      --build-name="$BUILD_NAME" \
      --build-number="$BUILD_NUMBER" \
      --split-debug-info=debug_symbols \
      --no-tree-shake-icons
else
    echo "Building APK..."
    flutter build apk --release \
      $VERBOSE \
      --obfuscate --split-debug-info=build/debug-info \
      --dart-define-from-file=env/$ENV.json \
      --build-name="$BUILD_NAME" \
      --build-number="$BUILD_NUMBER" \
      --split-debug-info=debug_symbols \
      --no-tree-shake-icons 
fi

# Check if build command succeeded
if [[ $? -ne 0 ]]; then
    echo "Error: $(echo "$BUILD_TYPE" | tr '[:lower:]' '[:upper:]') build failed. Please check the error log above!"
    exit 1
fi

# Verify output file existence
if [[ ! -f "$SOURCE_OUTPUT_PATH" ]]; then
    echo "Error: Expected output file was not found at $SOURCE_OUTPUT_PATH. Build might have failed silently."
    exit 1
fi

# Ensure target directory exists
mkdir -p "$TARGET_OUTPUT_DIR"

# Copy and rename output file to target directory
echo "Copying and renaming output file to target directory..."
cp "$SOURCE_OUTPUT_PATH" "$TARGET_OUTPUT_PATH"

# Check if copy succeeded
if [[ $? -eq 0 ]]; then
    echo "$(echo "$BUILD_TYPE" | tr '[:lower:]' '[:upper:]') successfully generated and copied: $TARGET_OUTPUT_PATH"
else
    echo "Error: Failed to copy output file to $TARGET_OUTPUT_PATH. Please check permissions!"
    exit 1
fi

echo "----------------------------------------"
echo "Build process completed successfully!"

# Exit successfully
exit 0
