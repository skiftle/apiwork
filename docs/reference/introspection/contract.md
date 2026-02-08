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

contract.actions[:show].response  # => Action::Response
contract.types[:address].shape    # => { street: ..., city: ... }
contract.enums[:status].values    # => ["draft", "published"]

contract.actions.each_value do |action|
  action.request   # => Action::Request
  action.response  # => Action::Response
end
```

## Instance Methods

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L28)

**Returns**

Hash{Symbol =&gt; [Introspection::Action](/reference/introspection/action/)}

---

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L40)

**Returns**

Hash{Symbol =&gt; [Enum](/reference/introspection/enum)}

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L48)

Converts this contract to a hash.

**Returns**

`Hash`

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L34)

**Returns**

Hash{Symbol =&gt; [Type](/reference/introspection/type)}

---
