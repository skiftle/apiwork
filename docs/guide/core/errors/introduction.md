---
order: 1
---

# Introduction

Apiwork uses a unified error format. All errors share the same structure, so clients receive consistent responses regardless of where a request fails.

## Error Response

When something goes wrong, Apiwork returns an error response with two parts:

```json
{
  "layer": "contract",
  "issues": [
    {
      "code": "field_missing",
      "detail": "Required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": {}
    }
  ]
}
```

| Field    | Description                                   |
| -------- | --------------------------------------------- |
| `layer`  | Which part of the system rejected the request |
| `issues` | One or more problems found                    |

The `layer` tells you what kind of validation failed. The `issues` array tells you what specifically went wrong. A single request can have multiple issues, but they all belong to the same layer.

## The Issue Object

Each issue describes one specific problem:

| Field     | Description                    |
| --------- | ------------------------------ |
| `code`    | Machine-readable symbol        |
| `detail`  | Human-readable message         |
| `path`    | Location in request body       |
| `pointer` | JSON Pointer derived from path |
| `meta`    | Additional context             |

Clients iterate through issues to display messages or highlight fields using the path.

## Error Layers

Errors are categorized into layers. A response contains errors from only one layer — if contract validation fails, domain validation never runs. If you return an HTTP error manually, that takes precedence.

| Layer      | Meaning                             | HTTP Status |
| ---------- | ----------------------------------- | ----------- |
| `http`     | Transport-level response            | Varies      |
| `contract` | Request violates the API contract   | 400         |
| `domain`   | Domain rules rejected valid input   | 422         |

### `http`

Transport-level responses like "not found" or "forbidden". Apiwork provides 20 built-in codes. See [HTTP Errors](./http-errors.md).

### `contract`

Request shape, types, or constraints don't match the contract. See [Contract Errors](./contract-errors.md).

### `domain`

Request was valid but violated a domain rule. How these are generated depends on your adapter. See [Domain Errors](./domain-errors.md).
