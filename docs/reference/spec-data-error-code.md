---
order: 28
prev: false
next: false
---

# Spec::Data::ErrorCode

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/error_code.rb#L15)

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

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/error_code.rb#L31)

**Returns**

`String`, `nil` — error description

---

### #status

`#status`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/error_code.rb#L25)

**Returns**

`Integer` — HTTP status code (e.g., 422, 404)

---
