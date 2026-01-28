---
order: 40
prev: false
next: false
---

# Introspection::Action::Response

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L18)

Wraps action response definitions.

**Example: Response with body**

```ruby
response = action.response
response.body?        # => true
response.no_content?  # => false
response.body         # => Param for response body
```

**Example: No content response**

```ruby
response.no_content?  # => true
response.body?        # => false
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L26)

**Returns**

`Param`, `nil` — response body definition

---

### #body?

`#body?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L38)

**Returns**

`Boolean` — whether a body is defined

---

### #no_content?

`#no_content?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L32)

**Returns**

`Boolean` — whether this is a no-content response (204)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L44)

**Returns**

`Hash` — structured representation

---
