#!/usr/bin/env bash
set -euo pipefail

echo "=== Agent Setup Script ==="
echo ""

# --- Install uv (Astral) ---
if command -v uv &>/dev/null; then
    echo "[✓] uv already installed: $(uv --version)"
else
    echo "[*] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    echo "[✓] uv installed: $(uv --version)"
fi

# --- Install Cursor ---
if command -v cursor &>/dev/null; then
    echo "[✓] Cursor already installed"
else
    echo "[*] Installing Cursor..."
    CURSOR_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
    CURSOR_APPIMAGE="$HOME/.local/bin/cursor.AppImage"
    mkdir -p "$HOME/.local/bin"

    curl -L "$CURSOR_URL" -o "$CURSOR_APPIMAGE"
    chmod +x "$CURSOR_APPIMAGE"
    ln -sf "$CURSOR_APPIMAGE" "$HOME/.local/bin/cursor"
    echo "[✓] Cursor installed to $CURSOR_APPIMAGE"
fi

# --- Ensure ~/.local/bin is on PATH ---
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "[*] Adding ~/.local/bin to PATH in shell profile..."
    SHELL_RC="$HOME/.bashrc"
    [[ -n "${ZSH_VERSION:-}" ]] && SHELL_RC="$HOME/.zshrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    export PATH="$HOME/.local/bin:$PATH"
    echo "[✓] PATH updated (restart your shell or run: source $SHELL_RC)"
fi

# --- Set up Python project ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo ""
echo "[*] Setting up Python project in $SCRIPT_DIR..."

cd "$SCRIPT_DIR"
uv venv .venv
source .venv/bin/activate
uv pip install -e .

echo ""
echo "[✓] Python venv created and dependencies installed"

# --- Remind about .env ---
if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
    echo ""
    echo "[!] No .env file found. Create one with your API keys:"
    echo "    COINGLASS_API_KEY=..."
    echo "    HL_SECRET_KEY=..."
fi

echo ""
echo "=== Setup complete ==="
echo "  - uv:     $(uv --version)"
echo "  - python:  $(python --version 2>&1)"
echo "  - project: $SCRIPT_DIR"
echo ""
echo "To activate the venv: source $SCRIPT_DIR/.venv/bin/activate"
