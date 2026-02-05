---
order: 27
prev: false
next: false
---

# Adapter::Wrapper::Error::Default

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/error/default.rb#L22)

Default error response wrapper.

Passes serialized error data through unchanged.

**Example: Configuration**

```ruby
class MyAdapter < Adapter::Base
  error_wrapper Wrapper::Error::Default
end
```

**Example: Output**

```ruby
{
  "issues": [{ "code": "blank", "detail": "can't be blank", ... }],
  "layer": "domain"
}
```

## Class Methods

### .shape

`.shape(klass_or_callable = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L29)

Defines the response shape for contract generation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass_or_callable` | `Class, Proc, nil` | a Shape subclass or callable |

**Returns**

`Class`, `nil` — the shape class

---

## Instance Methods

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L11)

**Returns**

`Hash` — the serialized resource data

---
