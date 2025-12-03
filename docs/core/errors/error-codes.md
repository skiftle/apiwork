---
order: 5
---

# Error Codes

HTTP errors like "not found" or "forbidden" are part of every API. How you handle them is up to you — but consistency matters. Returning the same error format everywhere makes clients easier to build.

Apiwork provides `respond_with_error` for this. It returns errors in the same Issue format as contract and validation errors. One parser handles everything.

## rescue_from

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

This is optional. You decide how to structure error handling in your app.

## respond_with_error

Returns an error response in Issue format:

```ruby
respond_with_error :forbidden
```

```json
{
  "issues": [
    {
      "code": "forbidden",
      "detail": "Access denied",
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

| Parameter | Description |
|-----------|-------------|
| `code` | Error code symbol |
| `detail:` | Custom message (overrides i18n) |
| `path:` | Location in request body |
| `meta:` | Additional context |
| `i18n:` | Interpolation values for translation |

## Built-in Codes

Apiwork registers 20 common HTTP error codes:

| Code | Status |
|------|--------|
| `:bad_request` | 400 |
| `:unauthorized` | 401 |
| `:payment_required` | 402 |
| `:forbidden` | 403 |
| `:not_found` | 404 |
| `:method_not_allowed` | 405 |
| `:not_acceptable` | 406 |
| `:request_timeout` | 408 |
| `:conflict` | 409 |
| `:gone` | 410 |
| `:precondition_failed` | 412 |
| `:unsupported_media_type` | 415 |
| `:unprocessable_entity` | 422 |
| `:locked` | 423 |
| `:too_many_requests` | 429 |
| `:internal_server_error` | 500 |
| `:not_implemented` | 501 |
| `:bad_gateway` | 502 |
| `:service_unavailable` | 503 |
| `:gateway_timeout` | 504 |

## Custom Codes

Register domain-specific error codes:

```ruby
# config/initializers/error_codes.rb
Apiwork::ErrorCode.register :insufficient_funds, status: 402
Apiwork::ErrorCode.register :account_frozen, status: 403
```

Status must be 400-599.

## i18n

Error messages support translations. See the [i18n section](/core/i18n) for details.
