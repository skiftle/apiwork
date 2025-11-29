# Pagination

The adapter supports two pagination strategies.

## Page-Based Pagination

Default strategy. Uses page number and size.

### Configuration

```ruby
adapter do
  pagination do
    strategy :page
    default_size 20
    max_size 100
  end
end
```

### Request

```ruby
# Query parameters
{ page: { number: 1, size: 10 } }
{ page: { number: 2, size: 20 } }
```

### Response

```json
{
  "posts": [...],
  "pagination": {
    "current": 1,
    "total": 5,
    "items": 48
  }
}
```

## Cursor-Based Pagination

Uses opaque cursors for navigation.

### Configuration

```ruby
adapter do
  pagination do
    strategy :cursor
    default_size 20
    max_size 100
  end
end
```

### Request

```ruby
# First page
{ page: { size: 10 } }

# Next page
{ page: { after: "cursor_string", size: 10 } }

# Previous page
{ page: { before: "cursor_string", size: 10 } }
```

### Response

```json
{
  "activities": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTB9",
    "prev_cursor": "eyJpZCI6MX0"
  }
}
```

Cursors are `null` when there are no more pages.

## Default Behavior

Without pagination parameters, the default size is used:

```ruby
# No page parameter
GET /api/v1/posts
# Returns first 20 items (or whatever default_size is)
```

## Size Limits

The `max_size` prevents requesting too many items:

```ruby
# If max_size is 100
{ page: { size: 500 } }  # Will be limited to 100
```
