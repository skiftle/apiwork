---
order: 2
---

# Actions

Actions define the request and response structure for its endpoint.

```ruby
action :create do
  request do
    body do
      param :title, type: :string
    end
  end

  response do
    body do
      param :id, type: :integer
      param :title, type: :string
    end
  end
end
```

## Request

### query

For GET parameters:

```ruby
action :search do
  request do
    query do
      param :q, type: :string
    end
  end
end
```

### body

For POST/PATCH request body:

```ruby
action :create do
  request do
    body do
      param :post, type: :object do
        param :title, type: :string
        param :body, type: :string
      end
    end
  end
end
```

## Response

### body

Define the response structure:

```ruby
action :show do
  response do
    body do
      param :id, type: :integer
      param :title, type: :string
      param :created_at, type: :datetime
    end
  end
end
```

### replace

By default, contract responses are merged with schema responses. Use `replace: true` to completely override:

```ruby
action :destroy do
  response replace: true do
    body do
      param :deleted_id, type: :uuid
    end
  end
end
```

## Error Codes

Declare HTTP error codes that can be returned:

```ruby
action :show do
  error_codes 404, 403
end

action :create do
  error_codes 422
end
```

These appear in generated OpenAPI specs.
