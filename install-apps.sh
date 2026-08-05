#!/usr/bin/env bash
set -euo pipefail

echo "==> Prevent running as root"
if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script with sudo"
  exit 1
fi

install_opencode() {
  if command -v opencode >/dev/null 2>&1; then
    echo "opencode already installed"
    return
  fi
  echo "==> Installing opencode"
  curl -fsSL https://opencode.ai/install | bash
}

install_bun() {
  if command -v bun >/dev/null 2>&1; then
    echo "bun already installed"
    return
  fi
  echo "==> Installing bun"
  curl -fsSL https://bun.sh/install | bash
}

install_opencode
install_bun

echo "==> Done."
