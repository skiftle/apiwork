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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L18)

**Returns**

`String`, `nil`

---

### #status

`#status`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L24)

**Returns**

`Integer`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L32)

Converts this error code to a hash.

**Returns**

`Hash`

---
