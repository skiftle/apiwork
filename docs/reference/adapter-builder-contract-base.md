---
order: 13
prev: false
next: false
---

# Adapter::Builder::Contract::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L23)

Base class for Contract-phase type builders.

Contract phase runs once per contract with representation at registration time.
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

### #api_class

`#api_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base.api_class](contract-base#api-class)

---

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L78)

Builds contract-level types.

Override this method to generate types based on the representation.

**Returns**

`void`

---

### #contract_for

`#contract_for(representation_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base.contract_for](contract-base#contract-for)

---

### #enum

`#enum(name, values:, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base#enum](contract-base#enum)

---

### #enum?

`#enum?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base#enum?](contract-base#enum?)

---

### #import

`#import(type_name, from:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base#import](contract-base#import)

---

### #object

`#object(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base#object](contract-base#object)

---

### #scoped_enum_name

`#scoped_enum_name(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base#scoped_enum_name](contract-base#scoped-enum-name)

---

### #scoped_type_name

`#scoped_type_name(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base#scoped_type_name](contract-base#scoped-type-name)

---

### #type?

`#type?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base#type?](contract-base#type?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L56)

**See also**

- [Contract::Base#union](contract-base#union)

---
