# Apiwork Adapter

The built-in adapter for ActiveRecord models.

## Features

- **Pagination** - Page-based or cursor-based pagination
- **Filtering** - Query-based filtering with operators
- **Sorting** - Sort by attributes and associations
- **Eager Loading** - Automatic eager loading of includes

## Configuration

```ruby
Apiwork::API.draw '/api/v1' do
  adapter do
    pagination do
      strategy :page
      default_size 20
      max_size 100
    end
  end
end
```

## Options

### pagination

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `strategy` | Symbol | `:page` | `:page` or `:cursor` |
| `default_size` | Integer | 20 | Default page size |
| `max_size` | Integer | 100 | Maximum page size |

## Schema Attributes

Enable adapter features on schema attributes:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true, sortable: true
  attribute :created_at, filterable: true, sortable: true
  attribute :body, writable: true

  has_many :comments, schema: CommentSchema,
                      filterable: true,
                      sortable: true
end
```

| Option | Description |
|--------|-------------|
| `filterable: true` | Enable filtering on this attribute |
| `sortable: true` | Enable sorting on this attribute |
| `writable: true` | Allow in create/update requests |
