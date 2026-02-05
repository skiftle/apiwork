---
order: 28
prev: false
next: false
---

# Adapter::Wrapper::Error::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/error/base.rb#L24)

Base class for error response wrappers.

Error wrappers structure responses for validation errors and other
error conditions. Extend this class to customize how errors are
wrapped in your API responses.

**Example: Custom error wrapper**

```ruby
class MyErrorWrapper < Wrapper::Error::Base
  shape do
    extends(data_type)
  end

  def wrap
    data
  end
end
```

## Class Methods

### .shape

`.shape(klass_or_callable = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L25)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L12)

**Returns**

`Hash` — the serialized resource data

---

### #wrap

`#wrap`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L61)

Transforms the data into the final response format.

**Returns**

`Hash` — the wrapped response

---
