# Filtering

Filter your index routes with type-safe operators. Mark fields as `filterable: true` in your schema, and Apiwork generates the contract and query logic automatically.

## Basic syntax

### Shorthand (direct value)

```bash
GET /posts?filter[title]=Rails
```

Shorthand assumes `equal` operator. Equivalent to:

```bash
GET /posts?filter[title][equal]=Rails
```

### Full syntax (with operator)

```bash
GET /posts?filter[title][contains]=Rails
```

Explicitly specifies the operator.

## Operators by type

### String operators

```ruby
attribute :title, type: :string, filterable: true
```

**Available operators**:
- `equal` - Exact match
- `not_equal` - Not equal
- `contains` - Substring match (LIKE %value%)
- `not_contains` - Does not contain
- `starts_with` - Prefix match (LIKE value%)
- `ends_with` - Suffix match (LIKE %value)
- `in` - Match any in array
- `not_in` - Match none in array

**Examples**:
```bash
filter[title][equal]=Rails                    # title = 'Rails'
filter[title][contains]=Guide                 # title LIKE '%Guide%'
filter[title][starts_with]=Getting            # title LIKE 'Getting%'
filter[title][in][]=Rails&filter[title][in][]=Elixir  # title IN ('Rails', 'Elixir')
```

### Numeric operators (integer, decimal)

```ruby
attribute :views, type: :integer, filterable: true
```

**Available operators**:
- `equal` - Exact value
- `not_equal` - Not equal
- `greater_than` - Strict greater than
- `greater_than_or_equal_to` - Greater than or equal
- `less_than` - Strict less than
- `less_than_or_equal_to` - Less than or equal
- `between` - Range (inclusive)
- `not_between` - Outside range
- `in` - Match any in array
- `not_in` - Match none in array

**Examples**:
```bash
filter[views][greater_than]=100                             # views > 100
filter[views][between][from]=10&filter[views][between][to]=100  # views BETWEEN 10 AND 100
filter[views][in][]=50&filter[views][in][]=100             # views IN (50, 100)
```

### Date/DateTime operators

```ruby
attribute :created_at, type: :datetime, filterable: true
```

**Available operators**: Same as numeric (equal, greater_than, between, etc.)

**Format**: ISO 8601 strings

**Examples**:
```bash
filter[created_at][equal]=2024-01-15
filter[created_at][greater_than]=2024-01-01T00:00:00Z
filter[created_at][between][from]=2024-01-01&filter[created_at][between][to]=2024-12-31
filter[published_at][less_than]=2024-06-01
```

### Boolean operators

```ruby
attribute :published, type: :boolean, filterable: true
```

**Available operators**:
- `equal` - True or false

**Examples**:
```bash
filter[published][equal]=true
filter[published][equal]=false
filter[published]=true  # Shorthand
```

### UUID operators

```ruby
attribute :id, type: :uuid, filterable: true
```

**Available operators**:
- `equal` - Exact UUID match
- `not_equal` - Not this UUID
- `in` - Match any UUID in array
- `not_in` - Match no UUID in array

**Examples**:
```bash
filter[id][equal]=550e8400-e29b-41d4-a716-446655440000
filter[id][in][]=550e8400-e29b-41d4-a716-446655440000&filter[id][in][]=...
```

## Built-in filter types

Instead of marking individual attributes filterable, use built-in filter types:

```ruby
# Instead of this:
attribute :title, type: :string, filterable: true

# Schema can use:
attribute :title, type: :string_filter
```

**Available built-in types**:
- `:string_filter` - All string operators
- `:integer_filter` - All numeric operators + between
- `:decimal_filter` - All numeric operators + between
- `:boolean_filter` - Equal operator
- `:date_filter` - Date comparison + between
- `:datetime_filter` - DateTime comparison + between
- `:uuid_filter` - UUID equality + in

## AND logic (default)

Multiple filters in an object use AND logic:

```bash
GET /posts?filter[published][equal]=true&filter[title][contains]=Rails
```

```sql
WHERE published = true AND title LIKE '%Rails%'
```

## OR logic (array)

Use array syntax for OR logic:

```bash
GET /posts?filter[0][title][equal]=Rails&filter[1][title][equal]=Elixir
```

```sql
WHERE (title = 'Rails' OR title = 'Elixir')
```

## Association filtering

Filter by nested association fields:

```bash
GET /posts?filter[comments][author][equal]=Alice
```

```sql
SELECT DISTINCT posts.*
FROM posts
INNER JOIN comments ON comments.post_id = posts.id
WHERE comments.author = 'Alice'
```

**Requirements**:
- Association must be marked `filterable: true`
- Associated schema must have filterable attributes

**Examples**:
```bash
# Posts with comments by Alice
filter[comments][author][equal]=Alice

# Posts with comments containing "great"
filter[comments][content][contains]=great

# Nested: Posts with comments by users named Alice
filter[comments][user][name][equal]=Alice
```

## Complex examples

### Multiple conditions

```bash
GET /posts?filter[published][equal]=true&filter[views][greater_than]=100&filter[title][contains]=Rails
```

```sql
WHERE published = true AND views > 100 AND title LIKE '%Rails%'
```

### OR with AND

```bash
GET /posts?filter[0][title][contains]=Rails&filter[0][published][equal]=true&filter[1][title][contains]=Elixir&filter[1][published][equal]=true
```

```sql
WHERE (title LIKE '%Rails%' AND published = true)
   OR (title LIKE '%Elixir%' AND published = true)
```

### Association with multiple fields

```bash
GET /posts?filter[comments][author][equal]=Alice&filter[comments][created_at][greater_than]=2024-01-01
```

```sql
SELECT DISTINCT posts.*
FROM posts
INNER JOIN comments ON comments.post_id = posts.id
WHERE comments.author = 'Alice'
  AND comments.created_at > '2024-01-01'
```

## Generated SQL

Apiwork uses Arel to build WHERE clauses safely:

```ruby
# Input
{ filter: { title: { contains: 'Rails' }, published: { equal: true } } }

# Arel
Post.arel_table[:title].matches('%Rails%')
  .and(Post.arel_table[:published].eq(true))

# SQL
WHERE title LIKE '%Rails%' AND published = true
```

**Security**: All values are parameterized - no SQL injection possible.

## Next steps

- [Sorting](sorting.md) - Order your filtered results
- [Pagination](pagination.md) - Page through filtered results
- [Combining Queries](combining.md) - Filter + sort + paginate
