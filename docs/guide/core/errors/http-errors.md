---
order: 2
---

# HTTP Errors

HTTP errors are transport-level responses. They are status-driven and express outcomes through HTTP semantics — not input validation or business rules.

Use `respond_with_error` when you need to communicate an HTTP-level outcome like "not found", "forbidden", or "unauthorized".

## HTTP Status

**Varies (400-504)** — Status depends on the error code.

## Usage

```ruby
respond_with_error :forbidden
```

```json
{
  "errors": [
    {
      "layer": "http",
      "code": "forbidden",
      "detail": "Forbidden",
      "path": [],
      "pointer": "",
      "meta": {}
    }
  ]
}
```

### Parameters

```ruby
respond_with_error :conflict,
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
| `i18n:`   | Interpolation values for translation |

### rescue_from

A common pattern is to catch exceptions and return error codes:

```ruby
class ApplicationController < ActionController::API
  include Apiwork::Controller

  rescue_from ActiveRecord::RecordNotFound do
    respond_with_error :not_found
  end

  rescue_from Pundit::NotAuthorizedError do
    respond_with_error :forbidden
  end
end
```

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

Register domain-specific error codes:

```ruby
# config/initializers/error_codes.rb
Apiwork::ErrorCode.register :insufficient_funds, status: 402
Apiwork::ErrorCode.register :account_frozen, status: 403
```

Status must be 400-599.

## i18n

Error messages support translations. See the [i18n section](/guide/advanced/i18n) for details.

## Examples

### Not Found

```ruby
rescue_from ActiveRecord::RecordNotFound do |exception|
  respond_with_error :not_found,
    path: [:id],
    meta: { model: exception.model }
end
```

```json
{
  "errors": [
    {
      "layer": "http",
      "code": "not_found",
      "detail": "Not found",
      "path": ["id"],
      "pointer": "/id",
      "meta": { "model": "Invoice" }
    }
  ]
}
```

### Conflict

```ruby
def ship
  order = Order.find(params[:id])

  if order.shipped?
    return respond_with_error :conflict,
      detail: "Order already shipped",
      path: [:order, :status],
      meta: { current_status: order.status }
  end

  order.ship!
  respond order
end
```

```json
{
  "errors": [
    {
      "layer": "http",
      "code": "conflict",
      "detail": "Order already shipped",
      "path": ["order", "status"],
      "pointer": "/order/status",
      "meta": { "current_status": "shipped" }
    }
  ]
}
```

### Too Many Requests

```ruby
def create
  if rate_limit_exceeded?
    return respond_with_error :too_many_requests,
      meta: { retry_after: 60 }
  end

  # ...
end
```

```json
{
  "errors": [
    {
      "layer": "http",
      "code": "too_many_requests",
      "detail": "Too many requests",
      "path": [],
      "pointer": "",
      "meta": { "retry_after": 60 }
    }
  ]
}
```
