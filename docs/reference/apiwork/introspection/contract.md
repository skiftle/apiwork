---
order: 58
prev: false
next: false
---

# Contract

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L21)

Facade for introspected contract data.

Provides access to actions, types, and enums defined on this contract.

**Example**

```ruby
contract = InvoiceContract.introspect(expand: true)

contract.actions[:show].response # => Action::Response
contract.types[:address].shape # => { street: ..., city: ... }
contract.enums[:status].values # => ["draft", "published"]

contract.actions.each_value do |action|
  action.request # => Action::Request
  action.response # => Action::Response
end
```

## Instance Methods

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L30)

The actions for this contract.

**Returns**

Hash{Symbol =&gt; [Introspection::Action](/reference/apiwork/introspection/action/)}

---

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L46)

The enums for this contract.

**Returns**

Hash{Symbol =&gt; [Enum](/reference/apiwork/introspection/enum)}

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L54)

Converts this contract to a hash.

**Returns**

`Hash`

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L38)

The types for this contract.

**Returns**

Hash{Symbol =&gt; [Type](/reference/apiwork/introspection/type)}

---
