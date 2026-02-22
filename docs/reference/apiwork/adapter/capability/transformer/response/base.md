---
order: 23
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/transformer/response/base.rb#L20)

Base class for response transformers.

Response transformers modify responses before they are returned.
Register transformers in capabilities using [Capability::Base.response_transformer](/reference/apiwork/adapter/capability/base#response-transformer).

**Example: Add generated_at to response**

```ruby
class MyResponseTransformer < Capability::Transformer::Response::Base
  def transform
    response.transform_body { |body| body.merge(generated_at: Time.zone.now) }
  end
end
```

## Instance Methods

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/transformer/response/base.rb#L37)

Transforms the response.

**Returns**

[Response](/reference/response)

---
