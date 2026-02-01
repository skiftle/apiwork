---
order: 13
prev: false
next: false
---

# Adapter::Builder::Contract::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L23)

Base class for Contract-phase type builders.

Contract phase runs once per bound contract at registration time.
Use it to generate contract-specific types based on the representation.

**Example**

```ruby
class Builder
  class Contract < Adapter::Builder::Contract::Base
    def build
      object(representation_class.root_key.singular) do |object|
        # define resource shape
      end
    end
  end
end
```

## Instance Methods

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L48)

Builds contract-level types.

Override this method to generate types based on the representation.

**Returns**

`void`

---
