---
order: 34
prev: false
next: false
---

# Spec::Data::Response

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/response.rb#L19)

Wraps action response definitions.

**Example: Response with body**

```ruby
response = action.response
response.body?        # => true
response.no_content?  # => false
response.body         # => Param for response body
response.body_hash    # => raw hash for mappers
```

**Example: No content response**

```ruby
response.no_content?  # => true
response.body?        # => false
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/response.rb#L27)

**Returns**

[Param](param), `nil` — response body definition

**See also**

- [Param](param)

---

### #body?

`#body?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/response.rb#L39)

**Returns**

`Boolean` — whether a body is defined

---

### #body_hash

`#body_hash`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/response.rb#L45)

**Returns**

`Hash`, `nil` — raw body hash for mappers that need hash access

---

### #no_content?

`#no_content?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/response.rb#L33)

**Returns**

`Boolean` — whether this is a no-content response (204)

---
