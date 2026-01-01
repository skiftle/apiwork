---
order: 32
prev: false
next: false
---

# Spec::Data::Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/request.rb#L17)

Wraps action request definitions.

Contains query parameters and/or body parameters.

**Example**

```ruby
request = action.request
request.query?              # => true
request.body?               # => false
request.query[:page]        # => Param for page param
request.query_hash          # => raw hash for mappers
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/request.rb#L32)

**Returns**

`Hash{Symbol => Param}` — body parameters as Param objects

**See also**

- [Param](param)

---

### #body?

`#body?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/request.rb#L44)

**Returns**

`Boolean` — whether body parameters are defined

---

### #body_hash

`#body_hash`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/request.rb#L56)

**Returns**

`Hash` — raw body hash for mappers that need hash access

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/request.rb#L25)

**Returns**

`Hash{Symbol => Param}` — query parameters as Param objects

**See also**

- [Param](param)

---

### #query?

`#query?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/request.rb#L38)

**Returns**

`Boolean` — whether query parameters are defined

---

### #query_hash

`#query_hash`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/request.rb#L50)

**Returns**

`Hash` — raw query hash for mappers that need hash access

---
