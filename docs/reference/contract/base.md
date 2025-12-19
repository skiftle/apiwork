---
order: 55
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L5)

## Class Methods

### .action(action_name, replace: = false, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L178)

---

### .action_definition(action_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L196)

---

### .api_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L220)

---

### .api_path()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L211)

---

### .as_json()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L207)

---

### .define_action(action_name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L254)

---

### .enum(name, values: = nil, description: = nil, example: = nil, deprecated: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L130)

---

### .find_contract_for_schema(schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L83)

---

### .global_type(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L233)

---

### .identifier(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L41)

---

### .import(contract_class, as:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L159)

Imports types from another contract for reuse.

This allows referencing types defined in another contract by
prefixing them with the alias. Useful for sharing common types
like addresses or monetary values.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `contract_class` | `Class` | the contract class to import from |
| `as` | `Symbol` | alias prefix for imported types |

**Example**

```ruby
class OrderContract < Apiwork::Contract::Base
  import AddressContract, as: :address

  action :create do
    request do
      body do
        param :shipping, type: :address  # Uses AddressContract's type
      end
    end
  end
end
```

---

### .inherited(subclass)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L35)

---

### .introspect(action: = nil, locale: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L203)

---

### .parse_response(body, action)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L229)

---

### .register_sti_variants(*variant_schema_classes)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L92)

---

### .reset_build_state!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L110)

---

### .resolve_custom_type(type_name, visited: = Set.new)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L187)

---

### .resolve_enum(enum_name, visited: = Set.new)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L241)

---

### .resolve_type(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L237)

---

### .schema!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L68)

Links this contract to its schema using naming convention.

Looks up the schema class by replacing "Contract" with "Schema"
in the class name. For example, `UserContract.schema!` finds
`UserSchema`.

Call this method to enable auto-generation of request/response
types based on the schema's attributes.

**Returns**

`Class` — the associated schema class

**Example**

```ruby
class UserContract < Apiwork::Contract::Base
  schema!  # Links to UserSchema

  action :create do
    request { body { param :name } }
    response { body { param :id } }
  end
end
```

---

### .schema?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L106)

**Returns**

`Boolean` — 

---

### .schema_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L102)

---

### .scope_prefix()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L115)

---

### .scoped_name(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L250)

---

### .type(name, description: = nil, example: = nil, format: = nil, deprecated: = false, schema_class: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L124)

---

### .union(name, discriminator: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L134)

---

## Instance Methods

### #action_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L13)

Returns the value of attribute action_name.

---

### #body()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L13)

Returns the value of attribute body.

---

### #initialize(query:, body:, action_name:, coerce: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L18)

**Returns**

`Base` — a new instance of Base

---

### #invalid?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L30)

**Returns**

`Boolean` — 

---

### #issues()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L13)

Returns the value of attribute issues.

---

### #query()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L13)

Returns the value of attribute query.

---

### #valid?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L26)

**Returns**

`Boolean` — 

---
