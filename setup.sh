#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DST="$HOME/.claude/skills/mythos"

MYTHOS_URL="${MYTHOS_URL:-https://mythos.one}"

echo "=== MythOS Claude Code Setup ==="
echo ""

# 1. Prereq check
if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found. Install Claude Code first:"
  echo "  https://claude.ai/code"
  exit 1
fi

CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
echo "Claude Code version: $CLAUDE_VERSION"

# 2. Input validation
if [ -z "${MYTHOS_API_KEY:-}" ]; then
  echo ""
  echo "Error: MYTHOS_API_KEY is required."
  echo "  Generate one at Settings > Agents > API Keys in the MythOS app."
  echo ""
  echo "Usage:"
  echo "  MYTHOS_API_KEY=mtk_... MYTHOS_USERNAME=yourname $0"
  exit 1
fi

if [[ ! "$MYTHOS_API_KEY" =~ ^mtk_[0-9a-f]{64}$ ]]; then
  echo ""
  echo "Error: MYTHOS_API_KEY format is invalid."
  echo "  Expected: mtk_ followed by 64 hex characters."
  echo "  Got: ${MYTHOS_API_KEY:0:8}..."
  exit 1
fi

if [ -z "${MYTHOS_USERNAME:-}" ]; then
  echo ""
  echo "Error: MYTHOS_USERNAME is required."
  echo ""
  echo "Usage:"
  echo "  MYTHOS_API_KEY=mtk_... MYTHOS_USERNAME=yourname $0"
  exit 1
fi

echo "API Key: ${MYTHOS_API_KEY:0:8}..."
echo "Username: $MYTHOS_USERNAME"
echo "MythOS URL: $MYTHOS_URL"
echo ""

# 3. Check for existing skill files
SKIP_COPY=""
if [ -d "$SKILL_DST" ]; then
  echo "Existing skill found at $SKILL_DST"
  read -p "Overwrite? [y/N] " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Skipping skill file copy."
    SKIP_COPY=1
  fi
fi

# 4. Copy skill files
if [ -z "$SKIP_COPY" ]; then
  mkdir -p "$SKILL_DST/references"
  cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DST/SKILL.md"
  cp "$SCRIPT_DIR/references/api.md" "$SKILL_DST/references/api.md"
  cp "$SCRIPT_DIR/references/workflows.md" "$SKILL_DST/references/workflows.md"
  echo "Skill files installed to $SKILL_DST"
fi

# 5. Check existing MCP config
echo ""
if claude mcp list 2>/dev/null | grep -q "mythos"; then
  echo "MCP server 'mythos' already registered."
  read -p "Remove and re-register? [y/N] " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    claude mcp remove mythos 2>/dev/null || true
    echo "Removed existing MCP entry."
  else
    echo "Keeping existing MCP config. Done!"
    exit 0
  fi
fi

# 6. Register MCP server
echo "Registering MythOS MCP server..."
claude mcp add \
  --transport http \
  -H "x-mythos-key: $MYTHOS_API_KEY" \
  -H "x-mythos-username: $MYTHOS_USERNAME" \
  mythos "$MYTHOS_URL/api/mcp"

# 7. Post-check
echo ""
echo "Verifying registration..."
if claude mcp list 2>/dev/null | grep -q "mythos"; then
  echo "MCP server 'mythos' registered successfully."
else
  echo "Warning: Could not verify MCP registration. Check with: claude mcp list"
fi

# 8. Done
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Test it out:"
echo "  1. Open Claude Code: claude"
echo "  2. Try: \"list my MythOS tags\""
echo "  3. Or invoke directly: /mythos"
echo ""
echo "To update: git pull && re-run this script"
echo "To uninstall: claude mcp remove mythos && rm -rf ~/.claude/skills/mythos"
