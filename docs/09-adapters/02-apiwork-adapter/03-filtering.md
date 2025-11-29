# Filtering

Filter collections using query parameters.

## Enabling Filtering

Mark attributes as filterable in the schema:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true
  attribute :status, filterable: true
  attribute :created_at, filterable: true
end
```

## Basic Filtering

```ruby
# Exact match
{ filter: { title: { eq: 'Hello World' } } }

# Boolean
{ filter: { published: { eq: true } } }
```

## Operators

| Operator | Description |
|----------|-------------|
| `eq` | Equal to |
| `gt` | Greater than |
| `gte` | Greater than or equal |
| `lt` | Less than |
| `lte` | Less than or equal |
| `contains` | String contains |
| `starts_with` | String starts with |
| `ends_with` | String ends with |
| `in` | In array of values |

### Examples

```ruby
# Greater than
{ filter: { created_at: { gt: '2024-01-01' } } }

# Contains
{ filter: { body: { contains: 'Rails' } } }

# In array
{ filter: { id: { in: [1, 2, 3] } } }
```

## Logical Operators

### AND (implicit)

Multiple filters are combined with AND:

```ruby
{ filter: { published: { eq: true }, title: { contains: 'Rails' } } }
# WHERE published = true AND title LIKE '%Rails%'
```

### OR

```ruby
{ filter: { _or: [
  { title: { contains: 'Ruby' } },
  { title: { contains: 'Rails' } }
] } }
# WHERE title LIKE '%Ruby%' OR title LIKE '%Rails%'
```

### NOT

```ruby
{ filter: { _not: { title: { eq: 'Draft' } } } }
# WHERE NOT (title = 'Draft')
```

## Association Filtering

Filter by associated records:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema, filterable: true
end

# Filter posts by comment author
{ filter: { comments: { author: { eq: 'John' } } } }
```

## Null Filtering

Check for null values:

```ruby
{ filter: { archived_at: { eq: nil } } }
```
