#!/usr/bin/env bash

set -e
set -x

REPO_OWNER="yetone"
REPO_NAME="avante.nvim"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Set the target directory to clone the artifact
TARGET_DIR="${SCRIPT_DIR}/build"
TEMP_FILE="${TARGET_DIR}/temp.tar.gz"
# Get the artifact download URL based on the platform and Lua version
case "$(uname -s)" in
Linux*)
  PLATFORM="linux"
  ;;
Darwin*)
  PLATFORM="darwin"
  ;;
CYGWIN* | MINGW* | MSYS*)
  PLATFORM="windows"
  ;;
*)
  echo "Unsupported platform"
  exit 1
  ;;
esac

# Get the architecture (x86_64 or aarch64)
case "$(uname -m)" in
x86_64)
  ARCH="x86_64"
  ;;
aarch64)
  ARCH="aarch64"
  ;;
arm64)
  ARCH="aarch64"
  ;;
*)
  echo "Unsupported architecture"
  exit 1
  ;;
esac

# Set the Lua version (lua54 or luajit)
LUA_VERSION="${LUA_VERSION:-luajit}"

# Set the artifact name pattern
ARTIFACT_NAME_PATTERN="avante_lib-$PLATFORM-$ARCH-$LUA_VERSION"

test_command() {
    command -v "$1" >/dev/null 2>&1
}

test_gh_auth() {
    if gh api user >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
fi
mkdir -p "$TARGET_DIR"

if test_command "gh" && test_gh_auth; then
    echo "Using gh release download command"
    gh release download --repo "github.com/$REPO_OWNER/$REPO_NAME" --pattern "*$ARTIFACT_NAME_PATTERN*"  --dir "$TARGET_DIR"
    tar -zxv -C "$TARGET_DIR" -f "$TEMP_FILE"
else
    # Get the artifact download URL
    echo "Using curl command"
    ARTIFACT_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest/download/*$ARTIFACT_NAME_PATTERN*"


    mkdir -p "$TARGET_DIR"

    curl -L "$ARTIFACT_URL" -o "$TEMP_FILE"
    tar -zxv -C "$TARGET_DIR" -f "$TEMP_FILE"
fi
