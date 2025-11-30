---
order: 1
---

# Introspection

Introspection is the machine-readable representation of your API. You rarely use it directly — it powers spec generators like OpenAPI, TypeScript, and Zod behind the scenes.

## Usage

```ruby
Apiwork::API.introspect('/api/v1')
```

Returns a hash with everything about your API: resources, actions, types, and enums.

## Output Structure

The introspection format is designed to be as compact as possible while containing all information needed for spec generation.

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

Introspection is the foundation for:

- **OpenAPI specs** — generates `/openapi.json` endpoints
- **TypeScript types** — generates interfaces for frontend use
- **Zod schemas** — generates runtime validators for JavaScript/TypeScript
- **Custom generators** — build your own spec formats

See [Specs](../specs/introduction.md) for how to use these generators.
