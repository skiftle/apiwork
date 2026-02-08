---
order: 31
prev: false
next: false
---

# Default

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L27)

Defines the response shape for contract generation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass_or_callable` | `Class<Shape>, Proc, nil` | a Shape subclass or callable |

**Returns**

Class&lt;[Shape](/reference/adapter/wrapper/shape)&gt;, `nil`

---

## Instance Methods

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L14)

The data for this wrapper.

**Returns**

`Hash`

---
