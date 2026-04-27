#!/usr/bin/env bash
set -euo pipefail

PVM_INSTALL_DIR="${PVM_INSTALL_DIR:-$HOME/.local/bin}"
PVM_SHIMS_DIR="${PVM_SHIMS_DIR:-$HOME/.local/pvm/shims}"
PVM_SOURCE_URL="${PVM_SOURCE_URL:-https://raw.githubusercontent.com/thiagolepidus/pvm/main/bin/pvm}"
PVM_BIN="$PVM_INSTALL_DIR/pvm"
PATH_LINE="export PATH=\"$PVM_SHIMS_DIR:$PVM_INSTALL_DIR:\$PATH\""
BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
BREW_TAPS="shivammathur/php shivammathur/extensions"

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

homebrew_shellenv_command() {
  local brew_prefix

  if command -v brew >/dev/null 2>&1; then
    brew_prefix="$(brew --prefix)"
    if [ -x "$brew_prefix/bin/brew" ]; then
      echo "eval \"\$($brew_prefix/bin/brew shellenv)\""
      return 0
    fi
  fi

  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
  elif [ -x /opt/homebrew/bin/brew ]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  elif [ -x /usr/local/bin/brew ]; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"'
  else
    return 1
  fi
}

load_homebrew() {
  local shellenv

  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  shellenv="$(homebrew_shellenv_command || true)"
  if [ -n "$shellenv" ]; then
    eval "$shellenv"
  fi
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  echo "Homebrew not found. Installing Homebrew..."
  if command -v curl >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "$BREW_INSTALL_URL")"
  elif command -v wget >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(wget -qO- "$BREW_INSTALL_URL")"
  else
    echo "curl or wget is required to install Homebrew" >&2
    exit 1
  fi

  load_homebrew

  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew was installed, but brew is still not available in PATH" >&2
    exit 1
  fi
}

ensure_homebrew_taps() {
  local tap

  for tap in $BREW_TAPS; do
    brew tap "$tap"
  done
}

ensure_path() {
  local profile="${PVM_SHELL_PROFILE:-$(detect_shell_profile)}"
  local brew_line

  if [ -z "$profile" ]; then
    echo "Fish shell detected. Add this manually:"
    echo "  eval ($(brew --prefix)/bin/brew shellenv)"
    echo "  fish_add_path \$HOME/.local/pvm/shims \$HOME/.local/bin"
    return 0
  fi

  touch "$profile"

  brew_line="$(homebrew_shellenv_command || true)"
  if [ -n "$brew_line" ] && ! grep -F "$brew_line" "$profile" >/dev/null 2>&1; then
    {
      printf '\n'
      printf '# Homebrew\n'
      printf '%s\n' "$brew_line"
    } >> "$profile"
    echo "Added Homebrew to PATH in $profile"
  fi

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

load_homebrew
install_homebrew
ensure_homebrew_taps

mkdir -p "$PVM_INSTALL_DIR" "$PVM_SHIMS_DIR"
download_pvm
chmod +x "$PVM_BIN"
ensure_path

echo "pvm installed at $PVM_BIN"
echo "Restart your shell or run:"
if homebrew_shellenv_command >/dev/null 2>&1; then
  echo "  $(homebrew_shellenv_command)"
fi
echo "  $PATH_LINE"
