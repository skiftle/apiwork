---
order: 5
---

# Exports

Declare which exports to enable for this API.

## Declaration

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
end
```

## Configuration

Configure export options and endpoint behavior:

```ruby
export :openapi do
  key_format :camel

  endpoint do
    mode :always
    path '/openapi.json'
  end
end
```

Exports inherit [`key_format`](./configuration.md#key-format) from the API by default.

### Endpoint Mode

| Mode      | Behavior                              |
| --------- | ------------------------------------- |
| `:auto`   | Development only (default)            |
| `:always` | Always mount endpoint                 |
| `:never`  | Never mount endpoint (rake/code only) |

```ruby
export :openapi do
  endpoint do
    mode :auto  # Only in development (default)
  end
end

export :typescript do
  endpoint do
    mode :never  # Generate via rake task only
  end
end
```

### Custom Path

```ruby
export :openapi do
  endpoint do
    path '/openapi.json'  # Instead of /.openapi
  end
end
```

Default paths:

| Declaration          | Endpoint                  |
| -------------------- | ------------------------- |
| `export :openapi`    | `GET /api/v1/.openapi`    |
| `export :typescript` | `GET /api/v1/.typescript` |
| `export :zod`        | `GET /api/v1/.zod`        |

---

See [Exports](../exports/) for endpoints, rake tasks, and programmatic generation.

#### See also

- [Export reference](../../../reference/apiwork/export/base) — programmatic generation API
