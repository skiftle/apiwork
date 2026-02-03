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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L57)

Builds API-level types.

Override this method to register shared types.

**Returns**

`void`

---

### #enum

`#enum(name, values:, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L40)

**See also**

- [API::Base#enum](api-base#enum)

---

### #enum?

`#enum?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L40)

**See also**

- [API::Base#enum?](api-base#enum?)

---

### #object

`#object(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L40)

**See also**

- [API::Base#object](api-base#object)

---

### #type?

`#type?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L40)

**See also**

- [API::Base#type?](api-base#type?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L40)

**See also**

- [API::Base#union](api-base#union)

---
