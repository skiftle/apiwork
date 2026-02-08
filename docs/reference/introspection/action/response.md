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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L43)

Whether this response has a body.

**Returns**

`Boolean`

---

### #no_content?

`#no_content?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L35)

Whether this response has no content.

**Returns**

`Boolean`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/response.rb#L51)

Converts this response to a hash.

**Returns**

`Hash`

---
