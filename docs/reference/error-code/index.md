---
order: 46
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L73)

Finds an error code by key.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`key`** | `Symbol` |  | The error code key. |

</div>

**Returns**

[ErrorCode::Definition](/reference/error-code/definition), `nil`

**See also**

- [.find!](#find!)

**Example**

```ruby
Apiwork::ErrorCode.find(:not_found)
```

---

### .find!

`.find!(key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L73)

Finds an error code by key.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`key`** | `Symbol` |  | The error code key. |

</div>

**Returns**

[ErrorCode::Definition](/reference/error-code/definition)

**See also**

- [.find](#find)

**Example**

```ruby
Apiwork::ErrorCode.find!(:not_found)
```

---

### .register

`.register(key, attach_path: false, status:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code.rb#L73)

Registers a custom error code for use in API responses.

Error codes are used with `raises` declarations and `expose_error`
in controllers. Built-in codes (400-504) are pre-registered.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`key`** | `Symbol` |  | The unique identifier for the error code. |
| `attach_path` | `Boolean` | `false` | Include request path in error response. |
| **`status`** | `Integer` |  | The HTTP status code (must be 400-599). |

</div>

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
