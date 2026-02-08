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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L29)

**Returns**

`Hash{Symbol => Param}`

---

### #body?

`#body?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L41)

**Returns**

`Boolean`

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L23)

**Returns**

`Hash{Symbol => Param}`

---

### #query?

`#query?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L35)

**Returns**

`Boolean`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L49)

Converts this request to a hash.

**Returns**

`Hash`

---
