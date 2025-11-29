# Adapters

Adapters handle data loading, transformation, and response formatting.

## Built-in Adapter

Apiwork includes a built-in adapter that provides:

- Pagination (page-based and cursor-based)
- Filtering
- Sorting
- Eager loading of associations

## Configuration

Configure the adapter in your API definition:

```ruby
Apiwork::API.draw '/api/v1' do
  adapter do
    pagination do
      strategy :page        # or :cursor
      default_size 20
      max_size 100
    end
  end
end
```

## Per-Schema Configuration

Override adapter settings for specific schemas:

```ruby
class PostSchema < Apiwork::Schema::Base
  adapter do
    pagination do
      default_size 10
      max_size 50
    end
  end
end
```

## What Adapters Do

### Request Transformation

Transform incoming request parameters before validation.

### Collection Loading

Apply filters, sorting, and pagination to collections.

### Response Rendering

Format data for API responses, including:

- Serialization
- Pagination metadata
- Error formatting
