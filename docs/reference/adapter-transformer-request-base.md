---
order: 24
prev: false
next: false
---

# Adapter::Transformer::Request::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/request/base.rb#L27)

Base class for request transformers.

Request transformers modify requests before or after validation.
Register transformers in capabilities using [Capability::Base.request_transformer](capability-base#request-transformer).

**Example: Custom request transformer**

```ruby
class NormalizeParams < Transformer::Request::Base
  phase :before

  def transform
    request.with_query(normalized_query)
  end

  private

  def normalized_query
    request.query.transform_keys(&:downcase)
  end
end
```

## Class Methods

### .phase

`.phase(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/request/base.rb#L36)

Sets or gets the transformer phase.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, nil` | :before (pre-validation) or :after (post-validation) |

**Returns**

`Symbol` — the phase (defaults to :before)

---

## Instance Methods

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/request/base.rb#L54)

Transforms the request.

**Returns**

`Apiwork::Request` — the transformed request

---
