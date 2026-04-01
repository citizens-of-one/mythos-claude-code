---
name: mythos
description: >
  Interact with a MythOS knowledge library — search, read, create, and update memos,
  chat with a library using RAG, explore tags and connections, and browse communities.
  Use when the user mentions MythOS, their knowledge library, memos, or wants to
  interact with mythos.one. Auto-triggers on: "mythos", "my library", "my memos",
  "knowledge library", "memo library".
allowed-tools:
  - mcp__mythos__search_memos
  - mcp__mythos__read_memo
  - mcp__mythos__create_memo
  - mcp__mythos__update_memo
  - mcp__mythos__list_tags
  - mcp__mythos__chat_with_library
  - mcp__mythos__delta_sync
  - mcp__mythos__get_memo_index
  - mcp__mythos__list_communities
  - mcp__mythos__search_community_posts
  - Bash(curl *)
  - Bash(jq *)
---

# MythOS — Knowledge Library Integration

You have access to the user's MythOS knowledge library. MythOS is a platform for structured memos with tags, knowledge graphs, and AI-powered search. Use the tools below to help the user interact with their library.

If this skill doesn't auto-trigger, the user can invoke it with `/mythos`.

## Connection Check

Before using any MythOS tools, determine which mode you're operating in:

1. **MCP mode (preferred):** Try calling `mcp__mythos__list_tags`. If it succeeds, MCP is configured — use `mcp__mythos__*` tools for all operations.
2. **Curl fallback:** If MCP tools are unavailable, check for `$MYTHOS_API_KEY` and `$MYTHOS_USERNAME` environment variables. Use curl against `https://mythos.one/api/internal/*` with `-H "x-mythos-key: $MYTHOS_API_KEY"`.
3. **Not configured:** If neither is available, tell the user:
   > "MythOS isn't connected yet. Run the setup script from the MythOS repo:
   > ```
   > MYTHOS_API_KEY=mtk_... MYTHOS_USERNAME=yourname ./scripts/setup-claude-code.sh
   > ```
   > Or generate an API key at Settings > Agents in the MythOS app, then run:
   > ```
   > claude mcp add --transport http -H "x-mythos-key: YOUR_KEY" -H "x-mythos-username: YOUR_USERNAME" mythos https://mythos.one/api/mcp
   > ```"

## MCP Tools Reference

All 10 tools are available as `mcp__mythos__<tool_name>`. The username is injected automatically by the MCP server config — you do not need to pass it (except for `chat_with_library`).

### Core memo operations

| Tool | When to use | Key params |
|---|---|---|
| `get_memo_index` | Get a bird's-eye view of the library (titles, tags, IDs — no content) | none |
| `search_memos` | Find memos by keyword or tag | `query?`, `tags?`, `visibility?`, `fields?`, `limit?` |
| `read_memo` | Read full content of a specific memo | `memoId` (required), `section?` |
| `create_memo` | Create a new memo | `title` (required), `content?`, `tags?`, `visibility?` |
| `update_memo` | Update an existing memo's content | `memoId` (required), `content` (required), `tags?` |

### Discovery & sync

| Tool | When to use | Key params |
|---|---|---|
| `list_tags` | See all tags with usage counts | none |
| `delta_sync` | Check what changed since a timestamp | `since` (required, ISO 8601), `limit?` |

### AI & communities

| Tool | When to use | Key params |
|---|---|---|
| `chat_with_library` | Ask a RAG-powered question about the library | `username` (required), `message` (required), `threadId?` |
| `list_communities` | Browse public MythOS communities | `limit?` |
| `search_community_posts` | Search posts within a community | `communitySlug` (required), `query?`, `limit?` |

## Critical Rules

1. **Always read before updating.** `update_memo` replaces the full content. Call `read_memo` first, modify the content, then send the complete updated content.
2. **Use section extraction** when you only need part of a memo: `read_memo` with `section: "Objective"` returns just that heading's content.
3. **`chat_with_library` requires an explicit `username` parameter** — unlike other tools, the username is NOT auto-injected. Ask the user for their username if you don't know it.
4. **Default visibility is `unlisted`** when creating memos. Only set `public` if the user explicitly asks.
5. **Rate limit: 60 requests/min per key.** Batch your operations efficiently.

## Workflow Patterns

### Library overview
1. `get_memo_index` — scan titles and tags
2. Summarize the library's themes, topics, and organization

### Find and read
1. `search_memos` with `query` or `tags`
2. `read_memo` on the most relevant result
3. Optionally use `section` to extract a specific part

### Create a memo from conversation
1. Synthesize the conversation into markdown
2. `create_memo` with a descriptive title, content, and relevant tags
3. Report the memo ID back to the user

### Update/enrich a memo
1. `read_memo` to get current content
2. Modify content (add sections, fix formatting, add information)
3. `update_memo` with the full updated content and optionally updated tags

### Check recent changes
1. `delta_sync` with `since` set to a recent timestamp (e.g., yesterday)
2. Summarize what changed

### Explore by tag
1. `list_tags` to see all tags and counts
2. `search_memos` with `tags: "tagname"` to browse a specific tag

### Research across the library (RAG)
1. `chat_with_library` with the user's question and their username
2. The RAG system searches embeddings and returns an AI-synthesized answer

### Community browsing
1. `list_communities` to discover available communities
2. `search_community_posts` to find posts on a topic within a community

## Curl Fallback

If MCP is not configured, use these curl patterns with `$MYTHOS_API_KEY` and `$MYTHOS_USERNAME`:

```bash
# Search memos
curl -s "https://mythos.one/api/internal/memos?username=$MYTHOS_USERNAME&q=search+terms&limit=10" \
  -H "x-mythos-key: $MYTHOS_API_KEY" | jq .

# Read a memo
curl -s "https://mythos.one/api/internal/memos?id=MEMO_ID" \
  -H "x-mythos-key: $MYTHOS_API_KEY" | jq .

# Create a memo
curl -s -X POST "https://mythos.one/api/internal/memos" \
  -H "x-mythos-key: $MYTHOS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"title":"New Memo","content":"# Content here","username":"'"$MYTHOS_USERNAME"'","visibility":"unlisted"}' | jq .

# Update a memo
curl -s -X PATCH "https://mythos.one/api/internal/memos?id=MEMO_ID" \
  -H "x-mythos-key: $MYTHOS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content":"# Updated content"}' | jq .

# Get memo index
curl -s "https://mythos.one/api/internal/memos/index?username=$MYTHOS_USERNAME" \
  -H "x-mythos-key: $MYTHOS_API_KEY" | jq .

# Delta sync (changes since timestamp)
curl -s "https://mythos.one/api/internal/memos/changes?username=$MYTHOS_USERNAME&since=2026-03-28T00:00:00.000Z" \
  -H "x-mythos-key: $MYTHOS_API_KEY" | jq .

# RAG chat (SSE stream)
curl -s -X POST "https://mythos.one/api/chat" \
  -H "x-mythos-key: $MYTHOS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"libraryOwnerUsername":"'"$MYTHOS_USERNAME"'","message":"What do you know about AI?"}' 
```

For full endpoint documentation, see the [OpenAPI spec](https://mythos.one/api/internal/openapi) or [references/api.md](references/api.md).
