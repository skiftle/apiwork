---
order: 6
---

# Metadata

Metadata describes your API for documentation and export generation.

## Info

```ruby
Apiwork::API.define '/api/v1' do
  info do
    title 'My API'
    version '1.0.0'
    description 'Public API for my application'
  end
end
```

Available options:

```ruby
info do
  title 'My API'
  version '1.0.0'
  description 'Full description'
  summary 'Short summary'
  deprecated!
  terms_of_service 'https://example.com/tos'

  contact do
    name 'API Support'
    email 'api@example.com'
    url 'https://example.com/support'
  end

  license do
    name 'MIT'
    url 'https://opensource.org/licenses/MIT'
  end

  server do
    url 'https://api.example.com'
    description 'Production'
  end
  server do
    url 'https://staging-api.example.com'
    description 'Staging'
  end

  tags 'Posts', 'Comments', 'Users'
end
```

## Raises

Declare which errors all endpoints can raise:

```ruby
Apiwork::API.define '/api/v1' do
  raises :bad_request, :unauthorized, :forbidden, :not_found, :internal_server_error
end
```

These appear in generated [OpenAPI exports](../exports/openapi.md) as possible responses for all endpoints.

#### See also

- [API::Base reference](../../../reference/api/base.md) — `info` and `raises` methods
