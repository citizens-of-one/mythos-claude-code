# MythOS API Quick Reference

This is a condensed reference for curl fallback mode. For full schemas, see the [OpenAPI spec](https://mythos.one/api/internal/openapi).

All requests require `-H "x-mythos-key: YOUR_API_KEY"`.

Base URL: `https://mythos.one` (production) or `http://localhost:3003` (local dev).

---

## Search Memos

```
GET /api/internal/memos?username={username}&q={query}&tags={tags}&visibility={visibility}&fields={fields}&limit={limit}
```

| Param | Required | Description |
|---|---|---|
| `username` | Yes | Library owner's username |
| `q` | No | Search query (matches titles) |
| `tags` | No | Comma-separated tag filter |
| `visibility` | No | `public` or `unlisted` |
| `fields` | No | Comma-separated: `title,snippet,tags,content,header,visibility,author` |
| `limit` | No | Max results (default 50, max 200) |

---

## Read Memo

```
GET /api/internal/memos?id={memoId}
```

Returns full memo with content. To extract a section:

```
GET /api/internal/memos/{memoId}/section?heading={heading}
```

---

## Create Memo

```
POST /api/internal/memos
Content-Type: application/json

{
  "title": "Memo Title",
  "content": "# Markdown content",
  "username": "owner-username",
  "tags": ["tag1", "tag2"],
  "visibility": "unlisted"
}
```

---

## Update Memo

```
PATCH /api/internal/memos?id={memoId}
Content-Type: application/json

{
  "content": "# Full replacement content",
  "tags": ["updated-tags"]
}
```

**Warning:** Content is a full replacement, not a patch. Read first, then send updated content.

---

## Memo Index

```
GET /api/internal/memos/index?username={username}
```

Returns lightweight list: IDs, titles, tags, hashes. No content.

---

## Delta Sync

```
GET /api/internal/memos/changes?username={username}&since={ISO8601}&limit={limit}
```

Returns memos modified since the given timestamp.

---

## Embeddings

```
POST /api/internal/embed
Content-Type: application/json

{ "texts": ["text to embed"] }
```

Batch variant (max 100):

```
POST /api/internal/embed/batch
Content-Type: application/json

{ "texts": ["text1", "text2", ...] }
```

---

## Chat (RAG)

```
POST /api/chat
Content-Type: application/json

{
  "libraryOwnerUsername": "username",
  "message": "Your question",
  "threadId": "optional-thread-id"
}
```

Returns SSE stream. Rate limited: 100/hr authenticated, 10/hr anonymous.

---

## Communities

```
GET /api/internal/communities?limit={limit}
GET /api/internal/communities/{slug}/posts?query={query}&limit={limit}
```

---

## Rate Limits

| Scope | Limit |
|---|---|
| Agent API (`/api/internal/*`) | 60 req/min |
| Chat (authenticated) | 100 req/hr |
| Chat (anonymous) | 10 req/hr |

---

## Authentication

User API keys (`mtk_` prefix) are generated at **Settings > Agents > API Keys** in the MythOS app. Requires Scholar or Oracle plan.

Pass via header: `x-mythos-key: mtk_...`
