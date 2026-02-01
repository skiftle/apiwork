---
order: 12
prev: false
next: false
---

# Adapter::Builder::API::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L22)

Base class for API-phase type builders.

API phase runs once per API at initialization time.
Use it to register shared types used across all contracts.

**Example**

```ruby
class Builder
  class API < Adapter::Builder::API::Base
    def build
      enum :status, values: %w[active inactive]
      object(:error) { |object| object.string(:message) }
    end
  end
end
```

## Instance Methods

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L42)

Builds API-level types.

Override this method to register shared types.

**Returns**

`void`

---
