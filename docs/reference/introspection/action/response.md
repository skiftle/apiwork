---
order: 57
prev: false
next: false
---

# Response

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L27)

The body for this response.

**Returns**

`Param`, `nil`

---

### #body?

`#body?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L39)

**Returns**

`Boolean`

---

### #no_content?

`#no_content?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L33)

**Returns**

`Boolean`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L47)

Converts this response to a hash.

**Returns**

`Hash`

---
