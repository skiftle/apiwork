---
order: 15
prev: false
next: false
---

# ErrorCode

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L5)

## Class Methods

### .register

`.register(key, attach_path: false, status:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L49)

Registers a custom error code for use in API responses.

Error codes are used with `raises` declarations and `expose_error`
in controllers. Built-in codes (400-504) are pre-registered.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `Symbol` | unique identifier for the error code |
| `status` | `Integer` | HTTP status code (must be 400-599) |
| `attach_path` | `Boolean` | include request path in error response (default: false) |

**Returns**

`ErrorCode::Definition` — the registered error code

**Example: Register custom error code**

```ruby
Apiwork::ErrorCode.register :resource_locked, status: 423
```

**Example: With path attachment**

```ruby
Apiwork::ErrorCode.register :not_found, status: 404, attach_path: true
```

---
