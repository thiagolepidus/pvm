#!/usr/bin/env bash
set -euo pipefail

PVM_INSTALL_DIR="${PVM_INSTALL_DIR:-$HOME/.local/bin}"
PVM_SHIMS_DIR="${PVM_SHIMS_DIR:-$HOME/.local/pvm/shims}"
PVM_SOURCE_URL="${PVM_SOURCE_URL:-https://raw.githubusercontent.com/lepidus/pvm/main/bin/pvm}"
PVM_BIN="$PVM_INSTALL_DIR/pvm"
PATH_LINE="export PATH=\"$PVM_SHIMS_DIR:$PVM_INSTALL_DIR:\$PATH\""

detect_shell_profile() {
  case "${SHELL:-}" in
    */zsh) echo "$HOME/.zshrc" ;;
    */bash) echo "$HOME/.bashrc" ;;
    */fish) echo "" ;;
    *) echo "$HOME/.profile" ;;
  esac
}

download_pvm() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$PVM_SOURCE_URL" -o "$PVM_BIN"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$PVM_BIN" "$PVM_SOURCE_URL"
  else
    echo "curl or wget is required to install pvm" >&2
    exit 1
  fi
}

ensure_path() {
  local profile="${PVM_SHELL_PROFILE:-$(detect_shell_profile)}"

  if [ -z "$profile" ]; then
    echo "Fish shell detected. Add this manually:"
    echo "  fish_add_path \$HOME/.local/pvm/shims \$HOME/.local/bin"
    return 0
  fi

  touch "$profile"

  if grep -F "$PATH_LINE" "$profile" >/dev/null 2>&1; then
    return 0
  fi

  {
    printf '\n'
    printf '# pvm\n'
    printf '%s\n' "$PATH_LINE"
  } >> "$profile"

  echo "Added pvm to PATH in $profile"
}

mkdir -p "$PVM_INSTALL_DIR" "$PVM_SHIMS_DIR"
download_pvm
chmod +x "$PVM_BIN"
ensure_path

echo "pvm installed at $PVM_BIN"
echo "Restart your shell or run:"
echo "  $PATH_LINE"
