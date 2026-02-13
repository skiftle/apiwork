---
order: 46
prev: false
next: false
---

# Definition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L28)

Represents a registered error code.

Error codes define HTTP status codes and behavior for API errors.
Retrieved via [ErrorCode.find](/reference/introspection/error-code#find) or [ErrorCode.find!](/reference/introspection/error-code#find!).

**Example**

```ruby
error_code = Apiwork::ErrorCode.find!(:not_found)
error_code.key # => :not_found
error_code.status # => 404
error_code.attach_path? # => true
```

## Instance Methods

### #attach_path?

`#attach_path?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L33)

Whether this error code attaches the request path.

**Returns**

`Boolean`

---

### #description

`#description(locale_key: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L48)

The description for this error code.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `locale_key` | `String`, `nil` | `nil` | The I18n namespace for API-specific translations. |

</div>

**Returns**

`String`

**Example**

```ruby
error_code = Apiwork::ErrorCode.find!(:not_found)
error_code.description # => "Not Found"
error_code.description(locale_key: 'api/v1') # apiwork.apis.api/v1.error_codes.not_found.description
```

---

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
