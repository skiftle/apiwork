# Filtering

The `filterable` option enables query filtering on an attribute.

## Basic Usage

```ruby
attribute :title, filterable: true
attribute :status, filterable: true
attribute :created_at, filterable: true
```

## Query Format

Filters use nested hash syntax:

```
GET /api/v1/posts?filter[title][eq]=Hello
GET /api/v1/posts?filter[status][in][]=draft&filter[status][in][]=published
GET /api/v1/posts?filter[created_at][gte]=2024-01-01
```

## Operators by Type

### String

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[title][eq]=Hello` |
| `in` | In array | `filter[title][in][]=A&filter[title][in][]=B` |
| `contains` | Contains substring | `filter[title][contains]=ruby` |
| `starts_with` | Starts with | `filter[title][starts_with]=How` |
| `ends_with` | Ends with | `filter[title][ends_with]=?` |

### Integer / Float / Decimal

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[price][eq]=100` |
| `gt` | Greater than | `filter[price][gt]=50` |
| `gte` | Greater or equal | `filter[price][gte]=50` |
| `lt` | Less than | `filter[price][lt]=100` |
| `lte` | Less or equal | `filter[price][lte]=100` |
| `between` | Range (inclusive) | `filter[price][between][]=10&filter[price][between][]=50` |
| `in` | In array | `filter[price][in][]=10&filter[price][in][]=20` |

### Datetime / Date

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[created_at][eq]=2024-01-15` |
| `gt` | After | `filter[created_at][gt]=2024-01-01` |
| `gte` | On or after | `filter[created_at][gte]=2024-01-01` |
| `lt` | Before | `filter[created_at][lt]=2024-12-31` |
| `lte` | On or before | `filter[created_at][lte]=2024-12-31` |
| `between` | Range | `filter[created_at][between][]=2024-01-01&filter[created_at][between][]=2024-12-31` |

### Boolean

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[published][eq]=true` |

### UUID

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[id][eq]=abc-123` |
| `in` | In array | `filter[id][in][]=abc&filter[id][in][]=def` |

### Nullable Fields

Nullable attributes get an additional `null` operator:

```
GET /api/v1/posts?filter[deleted_at][null]=true   # WHERE deleted_at IS NULL
GET /api/v1/posts?filter[deleted_at][null]=false  # WHERE deleted_at IS NOT NULL
```

## Logical Operators

Combine filters with `_and`, `_or`, and `_not`:

```
# Posts that are published AND created after 2024
GET /api/v1/posts?filter[_and][0][published][eq]=true&filter[_and][1][created_at][gt]=2024-01-01

# Posts that are draft OR archived
GET /api/v1/posts?filter[_or][0][status][eq]=draft&filter[_or][1][status][eq]=archived

# Posts that are NOT published
GET /api/v1/posts?filter[_not][published][eq]=true
```

## Generated Filter Type

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true
  attribute :published, filterable: true
  attribute :created_at, filterable: true
end
```

```typescript
// TypeScript
interface PostFilter {
  title?: {
    eq?: string;
    in?: string[];
    contains?: string;
    starts_with?: string;
    ends_with?: string;
  };
  published?: {
    eq?: boolean;
  };
  created_at?: {
    eq?: string;
    gt?: string;
    gte?: string;
    lt?: string;
    lte?: string;
    between?: [string, string];
  };
  _and?: PostFilter[];
  _or?: PostFilter[];
  _not?: PostFilter;
}

// Zod
const PostFilterSchema = z.object({
  title: z.object({
    eq: z.string().optional(),
    in: z.array(z.string()).optional(),
    contains: z.string().optional(),
    starts_with: z.string().optional(),
    ends_with: z.string().optional()
  }).optional(),
  published: z.object({
    eq: z.boolean().optional()
  }).optional(),
  created_at: z.object({
    eq: z.string().optional(),
    gt: z.string().optional(),
    gte: z.string().optional(),
    lt: z.string().optional(),
    lte: z.string().optional(),
    between: z.tuple([z.string(), z.string()]).optional()
  }).optional(),
  _and: z.lazy(() => z.array(PostFilterSchema)).optional(),
  _or: z.lazy(() => z.array(PostFilterSchema)).optional(),
  _not: z.lazy(() => PostFilterSchema).optional()
});
```

## Association Filtering

See [Association Filtering](../03-associations/04-filtering-sorting.md) for filtering by related records.
