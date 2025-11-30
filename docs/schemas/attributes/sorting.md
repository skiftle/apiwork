---
order: 4
---

# Sorting

The `sortable` option enables ordering results by an attribute.

## Basic Usage

```ruby
attribute :title, sortable: true
attribute :created_at, sortable: true
```

## Query Format

```
GET /api/v1/posts?sort[created_at]=desc
GET /api/v1/posts?sort[title]=asc
```

## Sort Direction

| Value | Description |
|-------|-------------|
| `asc` | Ascending (A-Z, 0-9, oldest first) |
| `desc` | Descending (Z-A, 9-0, newest first) |

## Multiple Sort Fields

Sort by multiple fields in order of precedence:

```
GET /api/v1/posts?sort[published]=desc&sort[created_at]=desc
```

This sorts by `published` first, then by `created_at` within each group.

## Generated Sort Type

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, sortable: true
  attribute :created_at, sortable: true
  attribute :published, sortable: true
end
```

```typescript
// TypeScript
interface PostSort {
  title?: 'asc' | 'desc';
  created_at?: 'asc' | 'desc';
  published?: 'asc' | 'desc';
}

// Zod
const PostSortSchema = z.object({
  title: z.enum(['asc', 'desc']).optional(),
  created_at: z.enum(['asc', 'desc']).optional(),
  published: z.enum(['asc', 'desc']).optional()
});
```

## Default Sort

The adapter applies default sorting if none is specified. Override in your controller or adapter configuration.

## Association Sorting

See [Association Sorting](../associations/filtering-sorting.md) for sorting by related record fields.
