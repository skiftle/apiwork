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

The `layer` tells you *what kind* of validation failed. The `issues` array tells you *what specifically* went wrong. A single request can have multiple issues, but they all belong to the same layer.

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

::: info
Layer describes **which part of the system rejected the request** — not where the code lives.
:::

### `http`

Transport-level responses like "not found" or "forbidden". Status-driven, not tied to specific fields.

```json
{
  "layer": "http",
  "issues": [
    {
      "code": "not_found",
      "detail": "Not found",
      "path": [],
      "pointer": "",
      "meta": {}
    }
  ]
}
```

Apiwork provides 20 built-in codes. You can also register your own.

See [HTTP Issues](./http-issues.md) for all codes and how to create custom ones.

### `contract`

Request shape, types, or constraints don't match the contract. Client can fix by following the API specification.

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

See [Contract Issues](./contract-issues.md) for all 12 codes.

### `domain`

Request was valid but violated a domain rule. Client can only fix by changing the data itself.

```json
{
  "layer": "domain",
  "issues": [
    {
      "code": "min",
      "detail": "Too short",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": { "min": 3 }
    }
  ]
}
```

How domain issues are generated depends on your adapter. The standard adapter maps Rails validation errors automatically.

See [Domain Issues](./domain-issues.md) for the concept and [Standard Adapter: Validation](../adapters/standard-adapter/validation.md) for implementation details.
