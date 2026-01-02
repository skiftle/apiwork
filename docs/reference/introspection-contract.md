---
order: 32
prev: false
next: false
---

# Introspection::Contract

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L21)

Facade for introspected contract data.

Provides access to actions, types, and enums defined on a contract.

**Example**

```ruby
contract = InvoiceContract.introspect(expand: true)

contract.actions[:show].response  # => Action::Response
contract.types[:address].shape    # => { street: ..., city: ... }
contract.enums[:status].values    # => ["draft", "published"]

contract.actions.each_value do |action|
  action.request   # => Action::Request or nil
  action.response  # => Action::Response or nil
end
```

## Instance Methods

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L29)

**Returns**

`Hash{Symbol => Action}` — actions defined on this contract

**See also**

- [Action](introspection-action)

---

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L43)

**Returns**

`Hash{Symbol => Enum}` — enums defined or referenced by this contract

**See also**

- [Enum](introspection-enum)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L49)

**Returns**

`Hash` — structured representation

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L36)

**Returns**

`Hash{Symbol => Type}` — custom types defined or referenced by this contract

**See also**

- [Type](introspection-type)

---
