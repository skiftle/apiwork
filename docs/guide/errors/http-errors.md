---
order: 2
---

# HTTP Errors

HTTP errors are transport-level responses — status-driven, not tied to input validation or business rules.

Use `expose_error` when you need to communicate an HTTP-level outcome like "not found", "forbidden", or "unauthorized".

## Usage

```ruby
expose_error :forbidden
```

```json
{
  "layer": "http",
  "issues": [
    {
      "code": "forbidden",
      "detail": "Forbidden",
      "path": [],
      "pointer": "",
      "meta": {}
    }
  ]
}
```

## Parameters

```ruby
expose_error :conflict,
  detail: "Order already shipped",
  path: [:order, :status],
  meta: { current_status: "shipped" }
```

| Parameter | Description                          |
| --------- | ------------------------------------ |
| `code`    | Error code symbol (required)         |
| `detail:` | Custom message (overrides default)   |
| `path:`   | Location in request body             |
| `meta:`   | Additional context                   |

## Error Codes

Apiwork registers 20 common HTTP error codes:

| Code                     | Status | Detail                 |
| ------------------------ | ------ | ---------------------- |
| `bad_request`            | 400    | Bad request            |
| `unauthorized`           | 401    | Unauthorized           |
| `payment_required`       | 402    | Payment required       |
| `forbidden`              | 403    | Forbidden              |
| `not_found`              | 404    | Not found              |
| `method_not_allowed`     | 405    | Method not allowed     |
| `not_acceptable`         | 406    | Not acceptable         |
| `request_timeout`        | 408    | Request timeout        |
| `conflict`               | 409    | Conflict               |
| `gone`                   | 410    | Gone                   |
| `precondition_failed`    | 412    | Precondition failed    |
| `unsupported_media_type` | 415    | Unsupported media type |
| `unprocessable_entity`   | 422    | Unprocessable entity   |
| `locked`                 | 423    | Locked                 |
| `too_many_requests`      | 429    | Too many requests      |
| `internal_server_error`  | 500    | Internal server error  |
| `not_implemented`        | 501    | Not implemented        |
| `bad_gateway`            | 502    | Bad gateway            |
| `service_unavailable`    | 503    | Service unavailable    |
| `gateway_timeout`        | 504    | Gateway timeout        |

## Custom Codes

Register custom error codes:

```ruby
# config/initializers/error_codes.rb
Apiwork::ErrorCode.register :insufficient_funds, status: 402
Apiwork::ErrorCode.register :account_frozen, status: 403
```

Status must be 400-599.

#### See also

- [Issue reference](../../reference/issue.md) — issue object structure
- [ErrorCode reference](../../reference/error-code/) — registering custom error codes
