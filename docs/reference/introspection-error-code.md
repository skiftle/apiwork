---
order: 31
prev: false
next: false
---

# Introspection::ErrorCode

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L24)

**Returns**

[String](introspection-string), `nil` — error description

---

### #status

`#status`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L18)

**Returns**

[Integer](introspection-integer) — HTTP status code (e.g., 422, 404)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L30)

**Returns**

`Hash` — structured representation

---
