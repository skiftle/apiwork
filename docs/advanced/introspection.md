---
order: 1
---

# Introspection

Your API as data. Introspection gives you a complete, machine-readable snapshot of your API — resources, actions, types, enums, everything.

You rarely use it directly. It powers spec generators like OpenAPI, TypeScript, and Zod behind the scenes.

## Usage

```ruby
Apiwork::API.introspect('/api/v1')
```

This returns a hash with your full API structure.

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

See [Spec Generation](../core/spec-generation/introduction.md) for details.
