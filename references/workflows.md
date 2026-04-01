# MythOS Workflow Recipes

Detailed step-by-step tool call sequences for common tasks.

---

## 1. Library Overview & Exploration

**Goal:** Understand what's in the user's library.

**Steps:**
1. Call `get_memo_index` (no params) — returns all memo IDs, titles, and tags
2. Analyze the index: count memos, identify tag clusters, find themes
3. Present a summary: "You have X memos across Y tags. Main themes: ..."
4. Offer to drill into specific areas with `search_memos` or `read_memo`

**Example output to user:**
> Your library has 47 memos across 23 tags. Top themes:
> - **Research** (12 memos): AI ethics, distributed systems, knowledge graphs
> - **Weekly** (8 memos): retrospectives and planning
> - **Draft** (5 memos): works in progress

---

## 2. Deep Research Across the Library

**Goal:** Answer a question using the library's knowledge.

**Steps:**
1. Call `chat_with_library` with `username` and the user's question
   - This triggers RAG: the system embeds the question, searches for relevant memo chunks, and generates a synthesized answer
2. If the answer references specific memos, call `read_memo` to get full context
3. Synthesize findings for the user

**When to use `chat_with_library` vs `search_memos`:**
- `chat_with_library` = semantic search + AI synthesis (best for questions)
- `search_memos` = keyword/tag search (best for finding specific memos)

---

## 3. Find, Read, and Summarize

**Goal:** Find a memo on a topic and summarize it.

**Steps:**
1. `search_memos` with `query: "topic"` or `tags: "tagname"`
2. Review results — pick the most relevant memo by title/snippet
3. `read_memo` with the memo ID
   - Use `section: "Heading"` if you only need a specific part
4. Summarize the content for the user

**Efficiency tip:** Use `fields: "title,snippet,tags"` in search to minimize response size when browsing.

---

## 4. Create a Memo from Conversation

**Goal:** Capture conversation insights as a new memo.

**Steps:**
1. Extract key points from the conversation
2. Structure as markdown with headings, lists, and content
3. Choose appropriate tags based on the topic
4. Call `create_memo` with:
   - `title`: descriptive, concise
   - `content`: well-structured markdown
   - `tags`: relevant tags (check `list_tags` first to reuse existing tags)
   - `visibility`: `unlisted` unless user says otherwise
5. Report the created memo ID and link to the user

**Markdown formatting tips:**
- Use `## Headings` for sections
- Use `- [ ] ` for checklists
- Use `@[Memo Title](/me/username/id)` for cross-references
- Use `#tagname` inline for hashtag references

---

## 5. Update and Enrich a Memo

**Goal:** Add content, fix formatting, or enrich tags on an existing memo.

**Steps:**
1. `read_memo` with the memo ID — get full current content
2. Modify the content:
   - Add new sections
   - Fix formatting or structure
   - Add cross-references to related memos
3. Optionally update tags (use `list_tags` to check existing tags)
4. `update_memo` with:
   - `memoId`: the memo ID
   - `content`: the **complete** updated content (not just the diff)
   - `tags`: updated tag list (if changed)

**Critical:** `update_memo` replaces the full content. Never send partial content.

---

## 6. Check Recent Activity

**Goal:** See what changed in the library recently.

**Steps:**
1. Calculate a timestamp (e.g., 24 hours ago, start of week)
2. Call `delta_sync` with `since: "2026-03-28T00:00:00.000Z"`
3. Summarize changes: new memos, updated memos, change types
4. Offer to read any interesting changes with `read_memo`

**Tip:** Pair with `get_memo_index` for context — the index gives you titles for the changed IDs.

---

## 7. Tag Exploration and Organization

**Goal:** Understand and manage the tag system.

**Steps:**
1. `list_tags` — see all tags with usage counts
2. Identify patterns: unused tags, similar tags that could be merged, heavily-used tags
3. To explore a tag: `search_memos` with `tags: "tagname"`
4. To retag memos: `read_memo` → `update_memo` with updated `tags` array

---

## 8. Community Browsing

**Goal:** Discover and explore MythOS communities.

**Steps:**
1. `list_communities` — see all public communities with descriptions and member counts
2. `search_community_posts` with `communitySlug` to browse a specific community
3. Add `query` to search within a community

---

## Error Handling

| Error | Likely cause | Fix |
|---|---|---|
| 401 Unauthorized | API key invalid or expired | Regenerate at Settings > Agents |
| 403 Forbidden | User's plan doesn't support API keys | Upgrade to Scholar or Oracle |
| 404 Not Found | Memo ID doesn't exist | Verify ID with `search_memos` |
| 429 Too Many Requests | Rate limit hit (60/min) | Wait and retry |
| MCP tool unavailable | MCP server not configured | Fall back to curl or run setup |
