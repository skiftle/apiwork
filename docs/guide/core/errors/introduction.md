---
order: 1
---

# Errors

Apiwork uses a unified error format. All errors share the same structure, so clients receive consistent responses regardless of where a request fails.

## The Issue Object

Every error is an `Issue`:

```ruby
Apiwork::Issue.new(
  layer: :contract,
  code: :field_missing,
  detail: "Required",
  path: [:invoice, :number],
  meta: { field: :number, type: :string }
)
```

| Field     | Description                                                    |
| --------- | -------------------------------------------------------------- |
| `layer`   | Which responsibility rejected: `http`, `contract`, or `domain` |
| `code`    | Machine-readable symbol                                        |
| `detail`  | Human-readable message                                         |
| `path`    | Location in request body                                       |
| `pointer` | JSON Pointer derived from path                                 |
| `meta`    | Additional context                                             |

## JSON Response

All errors render the same way:

```json
{
  "errors": [
    {
      "layer": "contract",
      "code": "field_missing",
      "detail": "Required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": { "field": "number", "type": "string" }
    }
  ]
}
```

The `errors` array contains all issues. Clients iterate through them, display messages, or highlight fields using the path.

## Error Layers

The `layer` field indicates which responsibility rejected the request. Validation runs in order: `http`, then `contract`, then `domain`. If a layer rejects the request, subsequent layers don't run.

| Layer      | Meaning                             | HTTP Status |
| ---------- | ----------------------------------- | ----------- |
| `http`     | Transport-level response            | Varies      |
| `contract` | Request violates the API contract   | 400         |
| `domain`   | Business rules rejected valid input | 422         |

::: info
Layer describes **which part of the system rejected the request** — not where the code lives.
:::

### http

Transport-level response like "not found" or "forbidden".

```json
{
  "layer": "http",
  "code": "not_found",
  "detail": "Not found",
  "path": [],
  "pointer": ""
}
```

Status-driven. Not tied to specific fields.

### contract

Request shape, types, or constraints don't match the contract.

```json
{
  "layer": "contract",
  "code": "field_missing",
  "detail": "Required",
  "path": ["invoice", "number"],
  "pointer": "/invoice/number"
}
```

Client can fix by following the API specification.

### domain

Request was valid but failed model validation or business rules.

```json
{
  "layer": "domain",
  "code": "min",
  "detail": "Too short",
  "path": ["invoice", "number"],
  "pointer": "/invoice/number",
  "meta": { "min": 3 }
}
```

Client can only fix by changing the data itself.

## Documentation

Each layer has dedicated documentation:

- [HTTP Errors](./http-errors.md) — `respond_with_error` and 20 built-in codes
- [Contract Errors](./contract-errors.md) — 28 codes for body, filter, sort, pagination
- [Domain Errors](./domain-errors.md) — 24 codes mapped from Rails validations
- [Custom Errors](./custom-errors.md) — Register your own error codes
