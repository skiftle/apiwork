---
order: 1
---

# Introspection

Your API as data. Introspection gives you a complete, machine-readable snapshot of your API — resources, actions, types, enums, everything.

You rarely use it directly. It powers spec generators like OpenAPI, TypeScript, and Zod behind the scenes.

## Usage

```ruby
# Uses current Rails locale (I18n.locale)
Apiwork::API.introspect('/api/v1')

# With specific locale
Apiwork::API.introspect('/api/v1', locale: :sv)
```

Returns a hash with your full API structure. Descriptions are localized based on the locale parameter (defaults to Rails' current locale).

## Output Structure

Compact but complete. Everything a spec generator needs:

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
            "body": { "type": "array", "of": "post" }
          }
        },
        "create": {
          "method": "POST",
          "path": "/",
          "request": {
            "body": {
              "title": { "type": "string", "required": true },
              "body": { "type": "string", "required": false }
            }
          },
          "response": {
            "body": { "type": "post" }
          }
        }
      }
    }
  },
  "types": {
    "post": {
      "type": "object",
      "shape": {
        "id": { "type": "integer" },
        "title": { "type": "string" },
        "body": { "type": "string" }
      }
    }
  },
  "enums": {
    "status": {
      "values": ["draft", "published", "archived"]
    }
  },
  "error_codes": [400, 404, 422]
}
```

## What It Powers

Introspection drives all spec generation:

- **OpenAPI** — `/openapi.json` endpoints
- **TypeScript** — type interfaces for your frontend
- **Zod** — runtime validators for JavaScript/TypeScript
- **Custom generators** — build your own formats

[Spec Generation](../core/spec-generation/introduction.md) covers how to enable spec endpoints and configure output formats.

## Field Types

Understanding these types is essential if you're building a custom spec generator. The introspection format is the foundation — OpenAPI, TypeScript, and Zod generators all read from this same structure.

Every field has a `type`. Here's the complete list:

### Primitive Types

| Type | Description | `min`/`max` meaning | `format` support |
|------|-------------|---------------------|------------------|
| `string` | Text | Character length | `email`, `uri`, `uuid` |
| `integer` | Whole number | Numeric value | - |
| `float` | Decimal number | Numeric value | - |
| `decimal` | High-precision decimal | Numeric value | - |
| `boolean` | True/false | - | - |
| `datetime` | ISO 8601 timestamp | - | `date-time` |
| `date` | ISO 8601 date only | - | `date` |
| `uuid` | UUID string | - | `uuid` |

### Container Types

| Type | Description | Required fields |
|------|-------------|-----------------|
| `array` | Ordered list | `of` (element type) |
| `object` | Key-value structure | `shape` (field definitions) |
| `union` | Multiple possible types | `variants` (array of types) |

### Special Types

| Type | Description | Required fields |
|------|-------------|-----------------|
| `literal` | Exact value match | `value` |
| Custom type name | Reference to defined type | - |
| Enum reference | Reference to defined enum | - |

## Field Properties

Properties describe the field's behavior. Not all properties apply to all types.

### Property Applicability

| Property | string | integer | float | boolean | date | array | object | union | literal |
|----------|--------|---------|-------|---------|------|-------|--------|-------|---------|
| `type` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `optional` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `nullable` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `default` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - | ✓ |
| `description` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `example` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| `format` | ✓ | - | - | - | ✓ | - | - | - | - |
| `deprecated` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `min` | length | value | value | - | - | length | - | - | - |
| `max` | length | value | value | - | - | length | - | - | - |
| `enum` | ✓ | ✓ | - | - | - | - | - | - | - |
| `of` | - | - | - | - | - | ✓ | - | - | - |
| `shape` | - | - | - | - | - | ✓* | ✓ | ✓* | - |
| `variants` | - | - | - | - | - | - | - | ✓ | - |
| `discriminator` | - | - | - | - | - | - | - | ✓ | - |
| `tag` | - | - | - | - | - | - | - | ✓ | - |
| `value` | - | - | - | - | - | - | - | - | ✓ |
| `as` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - |

\* `shape` on array: when `of: :object`. On union: inside each variant.

### Property Descriptions

| Property | Description |
|----------|-------------|
| `type` | The data type |
| `optional` | Field can be omitted from request |
| `nullable` | Field value can be `null` |
| `default` | Value used when field is omitted |
| `description` | Human-readable documentation |
| `example` | Sample value for documentation |
| `format` | Format hint (e.g., `email`, `uri`) |
| `deprecated` | Field should not be used |
| `min` | Minimum value (numbers) or length (strings/arrays) |
| `max` | Maximum value (numbers) or length (strings/arrays) |
| `enum` | Valid values (inline array or reference) |
| `of` | Element type for arrays |
| `shape` | Nested field definitions for objects |
| `variants` | Possible types for unions |
| `discriminator` | Field name that determines union variant |
| `tag` | Value that identifies a union variant |
| `value` | Exact value for literal type |
| `as` | Transformation alias (e.g., `comments_attributes`) |

## Compact Output

Introspection output is compact by design. Properties are **omitted** when they have no meaningful value:

| Property | Omitted when |
|----------|--------------|
| `optional` | `false` (default) |
| `nullable` | `false` (default) |
| `default` | `nil` |
| `description` | `nil` or empty |
| `example` | `nil` |
| `format` | `nil` |
| `deprecated` | `false` (default) |
| `min` | `nil` |
| `max` | `nil` |

This means a simple string field appears as just `{ "type": "string" }` rather than including all possible properties with null/false values.

## Building Custom Generators

Ready to build your own spec generator? See [Custom Specs](./custom-specs.md).
