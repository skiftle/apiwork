---
order: 30
prev: false
next: false
---

# Base

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L27)

Defines the response shape for contract generation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass_or_callable` | `Class<Shape>`, `Proc`, `nil` | `nil` | a Shape subclass or callable |

</div>

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

### #wrap

`#wrap`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L63)

Transforms the data into the final response format.

**Returns**

`Hash`

---
