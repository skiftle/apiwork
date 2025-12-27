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

The `layer` tells you *what kind* of validation failed. The `issues` array tells you *what specifically* went wrong. A single request can have multiple issues — like several missing fields — but they all belong to the same layer.

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

Validation runs in order: `http`, then `contract`, then `domain`. If a layer rejects the request, subsequent layers don't run. All errors in a response are from the same layer.

| Layer      | Meaning                             | HTTP Status |
| ---------- | ----------------------------------- | ----------- |
| `http`     | Transport-level response            | Varies      |
| `contract` | Request violates the API contract   | 400         |
| `domain`   | Domain rules rejected valid input   | 422         |

::: info
Layer describes **which part of the system rejected the request** — not where the code lives.
:::

### http

Transport-level response like "not found" or "forbidden".

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

Status-driven. Not tied to specific fields.

### contract

Request shape, types, or constraints don't match the contract.

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

Client can fix by following the API specification.

### domain

Request was valid but violated a domain rule.

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

Client can only fix by changing the data itself.

## Documentation

Each layer has dedicated documentation:

- [HTTP Issues](./http-issues.md) — `expose_error` and 20 built-in codes
- [Contract Issues](./contract-issues.md) — 28 codes for body, filter, sort, pagination
- [Domain Issues](./domain-issues.md) — 22 codes mapped from Rails validations
