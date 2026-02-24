---
order: 2
---

# HTTP Errors

HTTP errors are status-driven responses, not tied to input validation or business rules. Use `expose_error` to return HTTP errors like "not found", "forbidden", or "unauthorized".

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
| `bad_request`            | 400    | Bad Request            |
| `unauthorized`           | 401    | Unauthorized           |
| `payment_required`       | 402    | Payment Required       |
| `forbidden`              | 403    | Forbidden              |
| `not_found`              | 404    | Not Found              |
| `method_not_allowed`     | 405    | Method Not Allowed     |
| `not_acceptable`         | 406    | Not Acceptable         |
| `request_timeout`        | 408    | Request Timeout        |
| `conflict`               | 409    | Conflict               |
| `gone`                   | 410    | Gone                   |
| `precondition_failed`    | 412    | Precondition Failed    |
| `unsupported_media_type` | 415    | Unsupported Media Type |
| `unprocessable_entity`   | 422    | Unprocessable Entity   |
| `locked`                 | 423    | Locked                 |
| `too_many_requests`      | 429    | Too Many Requests      |
| `internal_server_error`  | 500    | Internal Server Error  |
| `not_implemented`        | 501    | Not Implemented        |
| `bad_gateway`            | 502    | Bad Gateway            |
| `service_unavailable`    | 503    | Service Unavailable    |
| `gateway_timeout`        | 504    | Gateway Timeout        |

## Custom Codes

Register custom error codes:

```ruby
# config/initializers/error_codes.rb
Apiwork::ErrorCode.register :insufficient_funds, status: 402
Apiwork::ErrorCode.register :account_frozen, status: 403
```

Status must be 400-599.

### attach_path

`attach_path: true` automatically includes the request path in the error response:

```ruby
Apiwork::ErrorCode.register :not_found, status: 404, attach_path: true
```

When `expose_error :not_found` is called from `/api/v1/invoices/42`:

```json
{
  "code": "not_found",
  "detail": "Not Found",
  "path": ["invoices", "42"],
  "pointer": "/invoices/42"
}
```

Without `attach_path`, `path` is empty. The built-in `:not_found` code has `attach_path: true` by default. All other built-in codes default to `false`.

A custom `path:` passed to `expose_error` overrides `attach_path`.

#### See also

- [Issue reference](../../reference/issue.md) — issue object shape
- [ErrorCode reference](../../reference/error-code/) — registering custom error codes
