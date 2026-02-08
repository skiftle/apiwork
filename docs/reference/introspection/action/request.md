---
order: 56
prev: false
next: false
---

# Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L16)

Wraps action request definitions.

Contains query parameters and/or body parameters.

**Example**

```ruby
request = action.request
request.query?              # => true
request.body?               # => false
request.query[:page]        # => Param for page param
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L33)

The body parameters for this request.

**Returns**

`Hash{Symbol => Param}`

---

### #body?

`#body?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L49)

Whether this request has a body.

**Returns**

`Boolean`

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L25)

The query parameters for this request.

**Returns**

`Hash{Symbol => Param}`

---

### #query?

`#query?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L41)

Whether this request has query parameters.

**Returns**

`Boolean`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L57)

Converts this request to a hash.

**Returns**

`Hash`

---
