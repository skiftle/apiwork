---
order: 43
prev: false
next: false
---

# ErrorCode

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L5)

## Modules

- [Definition](./definition)

## Class Methods

### .find

`.find(key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L68)

Finds an error code by key.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `Symbol` | the error code key |

**Returns**

[ErrorCode::Definition](/reference/error-code/definition), `nil`

**Example**

```ruby
Apiwork::ErrorCode.find(:not_found)
```

---

### .find!

`.find!(key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L68)

Finds an error code by key.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `Symbol` | the error code key |

**Returns**

[ErrorCode::Definition](/reference/error-code/definition)

**Example**

```ruby
Apiwork::ErrorCode.find!(:not_found)
```

---

### .register

`.register(key, attach_path: false, status:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L68)

Registers a custom error code for use in API responses.

Error codes are used with `raises` declarations and `expose_error`
in controllers. Built-in codes (400-504) are pre-registered.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `Symbol` | unique identifier for the error code |
| `status` | `Integer` | the HTTP status code (must be 400-599) |
| `attach_path` | `Boolean` | include request path in error response (default: false) |

**Returns**

[ErrorCode::Definition](/reference/error-code/definition)

**See also**

- [Issue](/reference/issue)

**Example: Register custom error code**

```ruby
Apiwork::ErrorCode.register :resource_locked, status: 423
```

**Example: With path attachment**

```ruby
Apiwork::ErrorCode.register :not_found, status: 404, attach_path: true
```

---

## Instance Methods

### #key

`#key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L28)

The key for this error code.

**Returns**

`Symbol`

---

### #status

`#status`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L28)

The status for this error code.

**Returns**

`Integer`

---
