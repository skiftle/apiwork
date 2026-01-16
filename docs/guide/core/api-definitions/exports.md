---
order: 5
---

# Exports

Declare which exports to enable as endpoints.

## Declaration

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
end
```

Each declaration creates an endpoint:

| Declaration          | Endpoint                  |
| -------------------- | ------------------------- |
| `export :openapi`    | `GET /api/v1/.openapi`    |
| `export :typescript` | `GET /api/v1/.typescript` |
| `export :zod`        | `GET /api/v1/.zod`        |

## Configuration

```ruby
export :openapi do
  path '/openapi.json'
  key_format :camel
end
```

Exports inherit [`key_format`](./configuration.md#key-format) from the API by default.

---

See [Exports](../exports/introduction.md) for endpoints, rake tasks, and programmatic generation.

#### See also

- [Export reference](../../../reference/export.md) — programmatic generation API
