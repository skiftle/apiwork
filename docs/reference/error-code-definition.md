---
order: 44
prev: false
next: false
---

# ErrorCode::Definition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L24)

Represents a registered error code.

Error codes define HTTP status codes and behavior for API errors.
Retrieved via [ErrorCode.find](introspection-error-code#find) or [ErrorCode.find!](introspection-error-code#find!).

**Example**

```ruby
error_code = Apiwork::ErrorCode.find!(:not_found)
error_code.key     # => :not_found
error_code.status  # => 404
error_code.attach_path? # => true
```

## Instance Methods

### #attach_path?

`#attach_path?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L29)

Whether to include request path in error response.

**Returns**

`Boolean`

---

### #description

`#description(locale_key: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L47)

Returns a localized description for the error code.

Looks up `apiwork.apis.&lt;locale_key&gt;.error_codes.&lt;key&gt;.description`,
falls back to `apiwork.error_codes.&lt;key&gt;.description`,
then to titleized key.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `locale_key` | `String, nil` | I18n namespace for API-specific translations |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L24)

**Returns**

`Symbol` — error code identifier

---

### #status

`#status`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/error_code/definition.rb#L24)

**Returns**

`Integer` — HTTP status code

---
