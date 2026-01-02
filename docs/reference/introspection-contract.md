---
order: 29
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

contract.actions.each do |action|
  action.name      # => :index, :show, etc.
  action.request   # => Action::Request or nil
  action.response  # => Action::Response or nil
end

contract.types.each { |t| ... }  # iterate custom types
contract.enums.each { |e| ... }  # iterate enums
```

## Instance Methods

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L29)

**Returns**

`Array<Action>` — actions defined on this contract

**See also**

- [Action](introspection-action)

---

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L47)

**Returns**

`Array<Enum>` — enums defined or referenced by this contract

**See also**

- [Enum](introspection-enum)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L55)

**Returns**

`Hash` — structured representation

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/contract.rb#L38)

**Returns**

`Array<Type>` — custom types defined or referenced by this contract

**See also**

- [Type](introspection-type)

---
