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
      object(representation_class.root_key.singular) do |o|
        # define resource shape
      end
    end
  end
end
```

## Instance Methods

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L50)

Builds contract-level types.

Override this method to generate types based on the representation.

**Returns**

`void`

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L26)

**Returns**

`Class` — the representation class for this contract

---
