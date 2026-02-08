---
order: 60
prev: false
next: false
---

# ErrorCode

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L11)

Wraps error code definitions.

**Example**

```ruby
api.error_codes[:not_found].status      # => 404
api.error_codes[:not_found].description # => "Resource not found"
```

## Instance Methods

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L20)

The description for this error code.

**Returns**

`String`, `nil`

---

### #status

`#status`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L28)

The HTTP status for this error code.

**Returns**

`Integer`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L36)

Converts this error code to a hash.

**Returns**

`Hash`

---
