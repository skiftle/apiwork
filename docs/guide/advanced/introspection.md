---
order: 1
---

# Introspection

Apiwork's internal representation of your API. A compact, machine-readable hash that contains everything: resources, actions, types, enums, error codes.

You rarely call it directly. Spec generators like [OpenAPI](../core/specs/open-api.md), [TypeScript](../core/specs/typescript.md), and [Zod](../core/specs/zod.md) read from this format internally. But if you're building a custom generator, you need to understand it.

::: warning Performance
Introspection is designed for development and build-time generation. It's slow. Don't call it on every request in production. Generate static files instead.
:::

## Two Levels

Apiwork provides introspection at two levels:

### API Introspection

The complete picture. Everything in your API.

```ruby
Apiwork::API.introspect('/api/v1')
Apiwork::API.introspect('/api/v1', locale: :sv)
```

Returns:
- All resources and nested resources
- All actions with their request/response definitions
- All types and enums (global and resource-scoped)
- Error codes and raises
- API metadata (title, version, description)

**Cached per locale.** First call builds everything. Subsequent calls return the cached hash.

### Contract Introspection

A single contract. Useful for development tools or debugging.

```ruby
InvoiceContract.introspect
InvoiceContract.introspect(locale: :sv)
InvoiceContract.introspect(expand: true)
```

Returns:
- Actions defined in the contract
- Types and enums scoped to this contract

**Not cached.** Computed on every call.

## The expand Parameter

By default, `Contract.introspect` returns only types defined in that contract.

```ruby
InvoiceContract.introspect
# => { actions: {...}, types: { invoice_filter: {...} } }
```

With `expand: true`, it walks the dependency graph and includes all referenced types:

```ruby
InvoiceContract.introspect(expand: true)
# => {
#   actions: {...},
#   types: {
#     invoice_filter: {...},
#     datetime_filter: {...},  # Referenced by invoice_filter
#     string_filter: {...},    # Referenced by invoice_filter
#     offset_pagination: {...} # Referenced in response
#   }
# }
```

This is useful when you need a self-contained snapshot of everything a contract uses.

## Output Structure

Compact by design. Only meaningful values are included.

```json
{
  "path": "/api/v1",
  "info": {
    "title": "My API",
    "version": "1.0.0"
  },
  "resources": {
    "posts": {
      "path": "posts",
      "actions": {
        "index": {
          "method": "GET",
          "path": "/",
          "response": {
            "body": {
              "type": "array",
              "of": "post"
            }
          }
        },
        "create": {
          "method": "POST",
          "path": "/",
          "request": {
            "body": {
              "title": {
                "type": "string"
              },
              "body": {
                "type": "string",
                "optional": true
              }
            }
          },
          "response": {
            "body": {
              "type": "post"
            }
          }
        }
      }
    }
  },
  "types": {
    "post": {
      "type": "object",
      "shape": {
        "id": {
          "type": "integer"
        },
        "title": {
          "type": "string"
        },
        "body": {
          "type": "string"
        }
      }
    }
  },
  "enums": {
    "status": {
      "values": ["draft", "published", "archived"]
    }
  },
  "error_codes": {
    "bad_request": {
      "status": 400,
      "description": "Bad Request"
    },
    "not_found": {
      "status": 404,
      "description": "Not Found"
    }
  }
}
```

Properties are omitted when they have default values:

| Property      | Omitted when      |
| ------------- | ----------------- |
| `optional`    | `false` (default) |
| `nullable`    | `false` (default) |
| `default`     | `nil`             |
| `description` | `nil` or empty    |
| `deprecated`  | `false` (default) |

A simple string field appears as `{ "type": "string" }`, not `{ "type": "string", "optional": false, "nullable": false, "deprecated": false }`.

## Performance and Production

Introspection is slow because it:

1. **Builds all contracts** - Walks every resource, registers contracts with the adapter
2. **Resolves type dependencies** - Expands type definitions, follows references
3. **Serializes deeply** - Recursively serializes all param structures

::: danger Don't call in production request handlers
Never do this:

```ruby
# Bad - runs introspection on every request
def spec
  render json: Apiwork::API.introspect('/api/v1')
end
```
:::

### For Production

Generate static files at build time:

```ruby
# In a Rake task or build script
File.write('public/api/introspection.json', Apiwork::API.introspect('/api/v1').to_json)
```

Or use the built-in [spec endpoints](../core/specs/introduction.md) with proper caching headers.

### Caching Behavior

| Method | Cached? | Notes |
|--------|---------|-------|
| `API.introspect` | Yes | Per locale, on the API class |
| `Contract.introspect` | No | Computed each call |
| Spec generators | Yes | Use API.introspect internally |

The API cache persists for the application lifetime. Call `API.reset_contracts!` to clear it (useful in development with code reloading).

## Field Types

If you're building a custom spec generator, you need to map these types.

### Primitive Types

| Type       | Description            | `min`/`max` meaning | `format` support       |
| ---------- | ---------------------- | ------------------- | ---------------------- |
| `string`   | Text                   | Character length    | `email`, `uri`, `uuid` |
| `integer`  | Whole number           | Numeric value       | -                      |
| `float`    | Decimal number         | Numeric value       | -                      |
| `decimal`  | High-precision decimal | Numeric value       | -                      |
| `boolean`  | True/false             | -                   | -                      |
| `datetime` | ISO 8601 timestamp     | -                   | `date-time`            |
| `date`     | ISO 8601 date only     | -                   | `date`                 |
| `uuid`     | UUID string            | -                   | `uuid`                 |

### Container Types

| Type     | Description             | Required fields             |
| -------- | ----------------------- | --------------------------- |
| `array`  | Ordered list            | `of` (element type)         |
| `object` | Key-value structure     | `shape` (field definitions) |
| `union`  | Multiple possible types | `variants` (array of types) |

### Special Types

| Type             | Description               | Required fields |
| ---------------- | ------------------------- | --------------- |
| `literal`        | Exact value match         | `value`         |
| Custom type name | Reference to defined type | -               |
| Enum reference   | Reference to defined enum | -               |

## Field Properties

| Property        | Description                                        |
| --------------- | -------------------------------------------------- |
| `type`          | The data type                                      |
| `optional`      | Field can be omitted from request                  |
| `nullable`      | Field value can be `null`                          |
| `default`       | Value used when field is omitted                   |
| `description`   | Human-readable documentation                       |
| `example`       | Sample value for documentation                     |
| `format`        | Format hint (e.g., `email`, `uri`)                 |
| `deprecated`    | Field should not be used                           |
| `min`           | Minimum value (numbers) or length (strings/arrays) |
| `max`           | Maximum value (numbers) or length (strings/arrays) |
| `enum`          | Valid values (inline array or reference)           |
| `of`            | Element type for arrays                            |
| `shape`         | Nested field definitions for objects               |
| `variants`      | Possible types for unions                          |
| `discriminator` | Field name that determines union variant           |
| `tag`           | Value that identifies a union variant              |
| `value`         | Exact value for literal type                       |
| `as`            | Transformation alias (e.g., `comments_attributes`) |

### Property Applicability

| Property        | string | integer | float | boolean | date | array  | object | union | literal |
| --------------- | ------ | ------- | ----- | ------- | ---- | ------ | ------ | ----- | ------- |
| `type`          | ✓      | ✓       | ✓     | ✓       | ✓    | ✓      | ✓      | ✓     | ✓       |
| `optional`      | ✓      | ✓       | ✓     | ✓       | ✓    | ✓      | ✓      | ✓     | ✓       |
| `nullable`      | ✓      | ✓       | ✓     | ✓       | ✓    | ✓      | ✓      | ✓     | ✓       |
| `default`       | ✓      | ✓       | ✓     | ✓       | ✓    | ✓      | ✓      | -     | ✓       |
| `description`   | ✓      | ✓       | ✓     | ✓       | ✓    | ✓      | ✓      | ✓     | ✓       |
| `example`       | ✓      | ✓       | ✓     | ✓       | ✓    | ✓      | ✓      | ✓     | -       |
| `format`        | ✓      | -       | -     | -       | ✓    | -      | -      | -     | -       |
| `deprecated`    | ✓      | ✓       | ✓     | ✓       | ✓    | ✓      | ✓      | ✓     | ✓       |
| `min`           | length | value   | value | -       | -    | length | -      | -     | -       |
| `max`           | length | value   | value | -       | -    | length | -      | -     | -       |
| `enum`          | ✓      | ✓       | -     | -       | -    | -      | -      | -     | -       |
| `of`            | -      | -       | -     | -       | -    | ✓      | -      | -     | -       |
| `shape`         | -      | -       | -     | -       | -    | ✓\*    | ✓      | ✓\*   | -       |
| `variants`      | -      | -       | -     | -       | -    | -      | -      | ✓     | -       |
| `discriminator` | -      | -       | -     | -       | -    | -      | -      | ✓     | -       |
| `tag`           | -      | -       | -     | -       | -    | -      | -      | ✓     | -       |
| `value`         | -      | -       | -     | -       | -    | -      | -      | -     | ✓       |
| `as`            | ✓      | ✓       | ✓     | ✓       | ✓    | ✓      | ✓      | ✓     | -       |

\* `shape` on array: when `of: :object`. On union: inside each variant.

## Conditional Type Generation

Types are generated only when needed:

| Type                                 | Generated when                               |
| ------------------------------------ | -------------------------------------------- |
| `error_response_body`                | API has at least one resource                |
| `offset_pagination`                  | At least one resource uses offset pagination |
| `cursor_pagination`                  | At least one resource uses cursor pagination |
| `sort_direction`                     | At least one attribute is sortable           |
| Filter types (`string_filter`, etc.) | At least one attribute is filterable         |
| `*_filter`                           | Schema has filterable attributes             |
| `*_sort`                             | Schema has sortable attributes               |
| `*_create_payload`                   | Schema has writable attributes + create action |
| `*_update_payload`                   | Schema has writable attributes + update action |

## Building Custom Generators

To build a custom spec generator, you need to:

1. Read the introspection output
2. Walk the structure and map to your target format
3. Handle all field types and properties

See [Custom Specs](./custom-specs.md) for implementation details.

::: info
All built-in generators (OpenAPI, TypeScript, Zod) read from this same format. The introspection output is the single source of truth.
:::
