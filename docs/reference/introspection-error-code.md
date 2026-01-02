---
order: 31
prev: false
next: false
---

# Introspection::ErrorCode

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L14)

Wraps error code definitions.

**Example**

```ruby
data.error_codes.each do |error_code|
  error_code.code         # => :not_found
  error_code.status       # => 404
  error_code.description  # => "Resource not found"
end
```

## Instance Methods

### #code

`#code`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L17)

**Returns**

`Symbol` — error code identifier

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L32)

**Returns**

`String`, `nil` — error description

---

### #status

`#status`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L26)

**Returns**

`Integer` — HTTP status code (e.g., 422, 404)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/error_code.rb#L38)

**Returns**

`Hash` — structured representation

---
