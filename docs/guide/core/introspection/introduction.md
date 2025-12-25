---
order: 1
---

# Introduction

Introspection is a core part of Apiwork. It allows your API to describe itself: resources, actions, types, enums, and errors are exposed as structured data that reflects how the system actually behaves.

Consumers don't need parallel definitions or separate interpretations. Generators, documentation, and integrations read the same information the framework uses internally. This removes guesswork and reduces drift between code, docs, and anything that depends on the API.

The practical outcome is consistency:

- [Specs](../specs/introduction.md) are generated without re-implementing rules
- Documentation stays aligned with the actual API surface
- Type definitions evolve with the code instead of diverging
- Internal tools can trust what they read

The output includes:

- Resources and actions
- Request and response shapes
- Types and enums
- Registered error codes
- API metadata (title, version, description)

```json
{
  "path": "/api/v1",
  "resources": {
    "invoices": {
      "path": "invoices",
      "actions": {
        "index": {
          "method": "get",
          "path": "/",
          "response": {
            "body": {
              "type": "invoice_index_success_response_body"
            }
          }
        },
        "show": {
          "method": "get",
          "path": "/:id"
        },
        "create": {
          "method": "post",
          "path": "/",
          "request": {
            "body": {
              "invoice": {
                "type": "invoice_create_payload"
              }
            }
          },
          "raises": ["unprocessable_entity"]
        }
      }
    }
  },
  "types": {
    "invoice": {
      "type": "object",
      "shape": {
        "id": {
          "type": "string"
        },
        "number": {
          "type": "string"
        },
        "status": {
          "type": "string",
          "nullable": true
        }
      }
    }
  },
  "enums": {
    "sort_direction": {
      "values": ["asc", "desc"]
    }
  },
  "error_codes": {
    "unprocessable_entity": {
      "status": 422,
      "description": "Unprocessable Entity"
    }
  }
}
```

---

## Usage

Two levels of introspection:

- [API Introspection](./api-introspection.md) — returns the complete API
- [Contract Introspection](./contract-introspection.md) — returns a single contract

---

## See Also

- [Format](./format.md) — output structure reference
