---
order: 9
---
# Errors

Apiwork uses a unified error shape. All errors share the same shape, so clients receive consistent responses regardless of where a request fails.

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

Errors are grouped into layers. A response contains errors from only one layer — if contract validation fails, domain validation never runs. If an HTTP error is returned manually, that takes priority.

| Layer      | Meaning                             | HTTP Status |
| ---------- | ----------------------------------- | ----------- |
| `http`     | Transport-level response            | Varies      |
| `contract` | Request violates the API contract   | 400         |
| `domain`   | Domain rules rejected valid input   | 422         |

## Custom Error Codes

Custom error codes are registered for use with `raises` declarations:

```ruby
# config/initializers/apiwork.rb
Apiwork::ErrorCode.register :resource_locked, status: 423
Apiwork::ErrorCode.register :quota_exceeded, status: 429
```

| Parameter | Description |
|-----------|-------------|
| `key` | Unique symbol identifier |
| `status:` | HTTP status code (400-599) |
| `attach_path:` | Include request path in error response (default: `false`) |

Then use in the API definition:

```ruby
Apiwork::API.define '/api/v1' do
  raises :resource_locked, :quota_exceeded
end
```

Apiwork pre-registers 20 built-in codes (400-504). See [HTTP Errors](./http-errors.md) for the full list.

### `http`

Transport-level responses like "not found" or "forbidden". See [HTTP Errors](./http-errors.md).

### `contract`

Request shape, types, or constraints don't match the contract. See [Contract Errors](./contract-errors.md).

### `domain`

Request was valid but violated a domain rule. How these are generated depends on the adapter. See [Domain Errors](./domain-errors.md).
