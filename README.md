# MythOS Claude Code Skill

A [Claude Code](https://claude.ai/code) skill that connects your [MythOS](https://mythos.one) knowledge library to Claude Code. Search, read, create, and update memos, chat with your library using RAG, explore tags and connections, and browse communities — all from the CLI.

Requires a MythOS **Scholar** or **Oracle** plan.

## What You Can Do

- **Search your library** — find memos by keyword, tag, or visibility
- **Read and update memos** — view full content, edit, and enrich with tags
- **Create memos** — capture conversation insights directly into your library
- **Chat with your library** — ask questions answered by RAG over your knowledge base
- **Explore tags** — see usage counts and browse by topic
- **Track changes** — incremental sync to see what's new
- **Browse communities** — discover and search MythOS communities

## Quick Start

### 1. Generate an API Key

Go to **Settings > Agents > API Keys** in the [MythOS app](https://mythos.one) and generate a new key. Copy it — it's only shown once.

### 2. Run the Setup Script

```bash
git clone https://github.com/citizens-of-one/mythos-claude-code.git
cd mythos-claude-code
MYTHOS_API_KEY=mtk_your_key_here MYTHOS_USERNAME=your_username ./setup.sh
```

This does three things:
- Copies the skill files to `~/.claude/skills/mythos/`
- Registers the MythOS MCP server with Claude Code
- Verifies the setup

### 3. Use It

Open Claude Code in any directory:

```bash
claude
```

Then try:
- "Search my MythOS library for AI ethics"
- "List my tags"
- "Create a memo called 'Meeting Notes' with today's discussion"
- "What does my library say about distributed systems?"

The skill auto-triggers when you mention MythOS, memos, or your knowledge library. You can also invoke it directly with `/mythos`.

## Manual Setup

If you prefer not to use the setup script:

**1. Copy skill files:**

```bash
mkdir -p ~/.claude/skills/mythos/references
cp SKILL.md ~/.claude/skills/mythos/
cp references/api.md ~/.claude/skills/mythos/references/
cp references/workflows.md ~/.claude/skills/mythos/references/
```

**2. Register the MCP server:**

```bash
claude mcp add --transport http \
  -H "x-mythos-key: YOUR_API_KEY" \
  -H "x-mythos-username: YOUR_USERNAME" \
  mythos https://mythos.one/api/mcp
```

## How It Works

This skill uses MythOS's [Model Context Protocol (MCP)](https://mythos.one/api/mcp) server, which exposes 10 tools for interacting with your library. Claude Code connects to the MCP server over HTTP and authenticates with your API key.

### Available MCP Tools

| Tool | Description |
|---|---|
| `search_memos` | Search memos by query, tags, or visibility |
| `read_memo` | Read full memo content (with optional section extraction) |
| `create_memo` | Create a new memo with title, content, and tags |
| `update_memo` | Update an existing memo's content and tags |
| `list_tags` | List all tags with usage counts |
| `chat_with_library` | RAG-powered Q&A over your knowledge base |
| `delta_sync` | Get memos changed since a timestamp |
| `get_memo_index` | Lightweight index of all memos (no content) |
| `list_communities` | List public MythOS communities |
| `search_community_posts` | Search posts within a community |

### Fallback Mode

If MCP isn't configured, the skill falls back to direct API calls using `curl`. Set `MYTHOS_API_KEY` and `MYTHOS_USERNAME` as environment variables in your shell.

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- A MythOS account on the **Scholar** or **Oracle** plan
- An API key generated at Settings > Agents > API Keys

## Updating

To update to the latest version:

```bash
cd mythos-claude-code
git pull
MYTHOS_API_KEY=mtk_your_key MYTHOS_USERNAME=your_username ./setup.sh
```

The setup script will prompt before overwriting existing files.

## Uninstalling

```bash
claude mcp remove mythos
rm -rf ~/.claude/skills/mythos
```

## Rate Limits

| Scope | Limit |
|---|---|
| API calls | 60 requests/min |
| Chat (authenticated) | 100 requests/hr |

## Links

- [MythOS](https://mythos.one)
- [MythOS MCP Documentation](https://mythos.one/api/mcp)
- [OpenAPI Spec](https://mythos.one/api/internal/openapi)
- [Claude Code](https://claude.ai/code)

## License

MIT
