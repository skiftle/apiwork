---
order: 31
prev: false
next: false
---

# Introspection::Action::Request

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L31)

**Returns**

Hash{Symbol =&gt; [Param](contract-param)} — body parameters as Param objects

**See also**

- [Param](contract-param)

---

### #body?

`#body?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L43)

**Returns**

`Boolean` — whether body parameters are defined

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L24)

**Returns**

Hash{Symbol =&gt; [Param](contract-param)} — query parameters as Param objects

**See also**

- [Param](contract-param)

---

### #query?

`#query?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L37)

**Returns**

`Boolean` — whether query parameters are defined

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action/request.rb#L49)

**Returns**

`Hash` — structured representation

---
