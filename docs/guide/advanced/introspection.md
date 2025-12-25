---
order: 1
---

# Introspection

Apiwork exposes your API as data. Introspection returns a compact, machine-readable hash of your entire API or a single contract.

Spec generators read from this format: [OpenAPI](../core/specs/open-api.md), [TypeScript](../core/specs/typescript.md), and [Zod](../core/specs/zod.md). You can call `introspect` directly during development to debug what Apiwork built from your contracts and schemas.

The output includes:

- Resources and actions
- Request and response shapes
- Types and enums
- Registered error codes
- API metadata (title, version, description)

Introspection is the **single source of truth** for spec generation.

---

## API Introspection

Returns the complete API:

```ruby
Apiwork::API.introspect('/api/v1')
Apiwork::API.introspect('/api/v1', locale: :sv)
```

Includes:

- All resources and nested resources
- All actions with request and response definitions
- All types and enums (global and resource-scoped)
- Error codes that actions can raise
- API metadata

::: info
Results are **cached** per locale. The first call builds the structure; later calls use the cached version.
:::

---

## Contract Introspection

Returns introspection for a single contract:

```ruby
InvoiceContract.introspect
InvoiceContract.introspect(locale: :sv)
InvoiceContract.introspect(expand: true)
```

Includes:

- Actions defined on the contract
- Types and enums **scoped** to the contract

By default, referenced types are not included:

```ruby
InvoiceContract.introspect
# => { actions: {...}, types: { invoice_filter: {...} } }
```

When you pass `expand: true`, referenced types are resolved:

```ruby
InvoiceContract.introspect(expand: true)
# => {
#   actions: {...},
#   types: {
#     invoice_filter: {...},
#     datetime_filter: {...},
#     string_filter: {...},
#     offset_pagination: {...}
#   }
# }
```

::: info
Contract introspection is **cached** by locale and `expand`.
:::

---

## Output Structure

The structure is designed for machines.

Defaults are omitted to keep output small:

| Property      | Omitted when   |
| ------------- | -------------- |
| `optional`    | `false`        |
| `nullable`    | `false`        |
| `default`     | `nil`          |
| `description` | `nil` or empty |
| `deprecated`  | `false`        |

Example:

```json
{
  "path": "/api/v1",
  "info": { "title": "My API", "version": "1.0.0" },
  "resources": {
    "posts": {
      "path": "posts",
      "actions": {
        "index": {
          "method": "GET",
          "path": "/",
          "response": {
            "body": { "type": "array", "of": "post" }
          }
        }
      }
    }
  },
  "types": {
    "post": { "type": "object", "shape": { "id": { "type": "integer" } } }
  },
  "enums": { "status": { "values": ["draft", "published", "archived"] } },
  "error_codes": {
    "bad_request": { "status": 400, "description": "Bad Request" }
  }
}
```

A simple string becomes:

```json
{ "type": "string" }
```

---

## Types

If you build a custom spec generator, you must handle these types.

### Primitive Types

| Type               | Meaning            | `min`/`max` | Format                 |
| ------------------ | ------------------ | ----------- | ---------------------- |
| `string`           | text               | length      | `email`, `uri`, `uuid` |
| `integer`          | whole number       | value       | -                      |
| `float`, `decimal` | decimal number     | value       | -                      |
| `boolean`          | true/false         | -           | -                      |
| `datetime`         | ISO 8601 timestamp | -           | `date-time`            |
| `date`             | ISO 8601 date      | -           | `date`                 |
| `uuid`             | UUID string        | -           | `uuid`                 |

### Container and Composite Types

| Type           | Description                 | Required fields |
| -------------- | --------------------------- | --------------- |
| `array`        | ordered list                | `of`            |
| `object`       | structured fields           | `shape`         |
| `union`        | multiple possible types     | `variants`      |
| `literal`      | exact value                 | `value`         |
| custom type    | reference to a defined type | -               |
| enum reference | reference to a defined enum | -               |

---

## Field Properties

| Property        | Meaning                      |
| --------------- | ---------------------------- |
| `type`          | field type                   |
| `optional`      | omitted in requests          |
| `nullable`      | can be `null`                |
| `default`       | used when omitted            |
| `description`   | human-readable               |
| `example`       | documentation-only           |
| `format`        | format hint                  |
| `deprecated`    | field should not be used     |
| `min` / `max`   | numeric or length constraint |
| `enum`          | allowed values               |
| `of`            | array element type           |
| `shape`         | nested fields                |
| `variants`      | union alternatives           |
| `discriminator` | union routing field          |
| `tag`           | union variant identifier     |
| `value`         | literal                      |
| `as`            | Rails/JSON alias             |

---

## Conditional Type Generation

Apiwork generates helper types only when needed:

| Type                  | Generated when                       |
| --------------------- | ------------------------------------ |
| `error_response_body` | API has resources                    |
| `offset_pagination`   | any resource uses offset pagination  |
| `cursor_pagination`   | cursor pagination is used            |
| filter types          | attribute is filterable              |
| `*_filter`            | schema defines filterable attributes |
| `*_sort`              | schema defines sortable attributes   |
| `*_create_payload`    | writable attributes + create action  |
| `*_update_payload`    | writable attributes + update action  |

::: tip
If a generator expects a helper type, make sure your schema uses that capability.
:::

---

## Building Custom Generators

To implement a custom spec:

1. Call `Apiwork::API.introspect('/api/v1')`
2. Walk the structure
3. Map every field type and property

See [Custom Specs](./custom-specs.md) for extension guidance.
