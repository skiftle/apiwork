---
order: 4
---

# Pagination

Paginate collections using offset-based or cursor-based strategies.

## Configuration

Set pagination at the API level:

```ruby
Apiwork::API.draw '/api/v1' do
  adapter do
    pagination do
      strategy :offset        # or :cursor
      default_size 20
      max_size 100
    end
  end
end
```

| Option | Default | Description |
|--------|---------|-------------|
| `strategy` | `:offset` | `:offset` or `:cursor` |
| `default_size` | `20` | Items per page when not specified |
| `max_size` | `100` | Maximum allowed page size |

---

## Offset-Based Pagination

Traditional offset-based pagination. Good for UIs with page numbers.

### Query Format

```
GET /posts?page[number]=2&page[size]=20
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `page[number]` | `1` | Page number (1-based) |
| `page[size]` | `default_size` | Items per page |

### Response

```json
{
  "posts": [...],
  "pagination": {
    "current": 2,
    "next": 3,
    "prev": 1,
    "total": 5,
    "items": 100
  }
}
```

| Field | Description |
|-------|-------------|
| `current` | Current page number |
| `next` | Next page number (`null` if last) |
| `prev` | Previous page number (`null` if first) |
| `total` | Total number of pages |
| `items` | Total count of all records |

### Out of Range

Requesting a page beyond the last page returns an empty array with pagination metadata:

```json
{
  "posts": [],
  "pagination": {
    "current": 999,
    "next": null,
    "prev": 998,
    "total": 5,
    "items": 100
  }
}
```

---

## Cursor-Based Pagination

Keyset pagination using encoded cursors. Better for large datasets and real-time data.

### Configuration

```ruby
adapter do
  pagination do
    strategy :cursor
    default_size 20
  end
end
```

### Query Format

**First page:**

```
GET /posts?page[size]=20
```

**Next page:**

```
GET /posts?page[size]=20&page[after]=eyJpZCI6MTAwfQ
```

**Previous page:**

```
GET /posts?page[size]=20&page[before]=eyJpZCI6ODF9
```

| Parameter | Description |
|-----------|-------------|
| `page[size]` | Items per page |
| `page[after]` | Cursor for forward pagination |
| `page[before]` | Cursor for backward pagination |

Cannot use `after` and `before` in the same request.

### Response

```json
{
  "posts": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTAwfQ",
    "prev_cursor": "eyJpZCI6ODF9"
  }
}
```

| Field | Description |
|-------|-------------|
| `next_cursor` | Cursor for next page (`null` if last) |
| `prev_cursor` | Cursor for previous page (`null` if first) |

### Cursor Format

Cursors are base64-encoded JSON containing the primary key:

```json
{"id": 100}
```

Cursors are opaque to clients — don't parse or construct them manually.

### Limitations

- Composite primary keys are not supported
- No total count (calculating totals defeats the performance benefit)

---

## Per-Schema Override

Override pagination for specific schemas:

```ruby
class ActivitySchema < Apiwork::Schema::Base
  adapter do
    pagination do
      strategy :cursor
      default_size 50
      max_size 200
    end
  end
end
```

This overrides the API-level configuration for this schema only.

---

## Error Codes

| Code | Cause |
|------|-------|
| `invalid_cursor` | Cursor couldn't be decoded |

```json
{
  "issues": [{
    "code": "invalid_cursor",
    "detail": "Invalid pagination cursor",
    "path": ["page", "after"]
  }]
}
```

---

## Examples

See [Cursor Pagination](../../examples/cursor-pagination.md) for a complete working example with configuration and response format.
