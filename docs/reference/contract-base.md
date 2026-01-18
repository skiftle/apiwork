---
order: 21
prev: false
next: false
---

# Contract::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

Base class for API contracts.

Contracts define request/response structure for a resource.
Link to a schema with [.schema!](#schema!) for automatic serialization.
Define actions with [.action](#action) for custom validation and response shapes.

**Example: Basic contract**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema! InvoiceSchema
end
```

**Example: With custom actions**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema! InvoiceSchema

  action :create do
    request do
      body do
        string :title
        decimal :amount, min: 0
      end
    end
  end
end
```

## Class Methods

### .abstract!

`.abstract!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

Marks this contract as abstract.

Abstract contracts serve as base classes for other contracts.
Use this when creating application-wide base contracts that define
shared imports or configuration. Subclasses automatically become non-abstract.

**Returns**

`void`

**Example: Application base contract**

```ruby
class ApplicationContract < Apiwork::Contract::Base
  abstract!
end
```

---

### .abstract?

`.abstract?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

Returns whether this contract is abstract.

**Returns**

`Boolean` — true if abstract

---

### .action

`.action(action_name, replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L352)

Defines an action (endpoint) for this contract.

Actions describe the request/response contract for a specific
controller action. Use the block to define request parameters,
response format, and documentation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_name` | `Symbol` | the controller action name (:index, :show, :create, :update, :destroy, or custom) |
| `replace` | `Boolean` | replace existing action definition (default: false) |

**Returns**

[Contract::Action](contract-action) — the action definition

**See also**

- [Contract::Action](contract-action)

**Example: Basic CRUD action**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  action :show do
    request do
      query do
        string? :include
      end
    end
    response do
      body do
        uuid :id
      end
    end
  end
end
```

**Example: Action with full request/response**

```ruby
action :create do
  summary 'Create a new invoice'
  tags :billing

  request do
    body do
      integer :customer_id
      decimal :amount
    end
  end

  response do
    body do
      uuid :id
      string :status
    end
  end

  raises :not_found
  raises :unprocessable_entity
end
```

---

### .enum

`.enum(name, values: nil, description: nil, example: nil, deprecated: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L217)

Defines an enum scoped to this contract.

Enums define a set of allowed string values. In introspection
output, enums are namespaced with the contract's scope prefix.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | enum name |
| `values` | `Array<String>` | allowed string values |
| `description` | `String` | documentation description |
| `example` | `String` | example value for docs |
| `deprecated` | `Boolean` | mark as deprecated |

**See also**

- [API::Base](api-base)

**Example**

```ruby
enum :status, values: %w[draft sent paid]
```

**Example: Reference in contract**

```ruby
string :status, enum: :status
```

---

### .identifier

`.identifier(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L101)

The scope prefix for contract-scoped types.

Types, enums, and unions defined in this contract are namespaced
with this prefix in introspection output. For example, a type
`:address` becomes `:invoice_address` when identifier is `:invoice`.

If not set, prefix is derived from schema's root_key or class name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, String` | scope prefix (optional) |

**Returns**

`String`, `nil`

**Example: Custom scope prefix**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  identifier :billing

  object :address do
    string :street
  end
  # In introspection: object is named :billing_address
end
```

---

### .import

`.import(contract_class, as:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L279)

Imports types from another contract for reuse.

Imported types are accessed with a prefix matching the alias.
If UserContract defines a type `:address`, importing it as `:user`
makes it available as `:user_address`.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `contract_class` | `Class` | a [Contract::Base](contract-base) subclass to import from |
| `as` | `Symbol` | alias prefix for imported types |

**See also**

- [Contract::Base](contract-base)

**Example: Import types from another contract**

```ruby
# UserContract has: object :address, enum :role
class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user

  action :create do
    request do
      body do
        reference :shipping, to: :user_address  # user_ prefix
        string :role, enum: :user_role          # user_ prefix
      end
    end
  end
end
```

---

### .introspect

`.introspect(expand: false, locale: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L382)

Returns a hash representation of this contract's structure.

Includes all actions with their request/response definitions.
Useful for generating documentation or client code.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `locale` | `Symbol` | optional locale for translated descriptions |
| `expand` | `Boolean` | resolve all referenced types (local, imported, global) |

**Returns**

`Hash` — contract structure with :actions key

**Example**

```ruby
InvoiceContract.introspect
# => { actions: { create: { request: {...}, response: {...} } } }
```

**Example: With all available types**

```ruby
InvoiceContract.introspect(expand: true)
# => { actions: {...}, types: { local: {...}, imported: {...}, global: {...} } }
```

---

### .object

`.object(name, description: nil, example: nil, format: nil, deprecated: false, schema_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L178)

Defines a reusable object type scoped to this contract.

Objects are named parameter structures that can be referenced in
param definitions. In introspection output, objects are namespaced
with the contract's scope prefix (e.g., `:order_address`).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | object name |
| `description` | `String` | documentation description |
| `example` | `Object` | example value for docs |
| `format` | `String` | format hint for docs |
| `deprecated` | `Boolean` | mark as deprecated |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass for type inference |

**See also**

- [API::Object](api-object)

**Example: Define a reusable type**

```ruby
object :item do
  string :description
  decimal :amount
end
```

**Example: Reference in contract**

```ruby
array :items do
  reference :item
end
```

---

### .schema!

`.schema!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L138)

Links this contract to its schema using naming convention.

Looks up the schema class by replacing "Contract" with "Schema"
in the class name. Both must be in the same namespace.
For example, `Api::V1::UserContract.schema!` finds `Api::V1::UserSchema`.

Call this method to enable auto-generation of request/response
types based on the schema's attributes.

**Returns**

[Schema::Base](schema-base)

**See also**

- [Schema::Base](schema-base)

**Example**

```ruby
class Api::V1::UserContract < Apiwork::Contract::Base
  schema!  # Links to Api::V1::UserSchema

  action :create do
    request do
      body do
        param :name
      end
    end
    response do
      body do
        param :id
      end
    end
  end
end
```

---

### .union

`.union(name, discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L250)

Defines a discriminated union type scoped to this contract.

A union is a type that can be one of several variants,
distinguished by a discriminator field. In introspection
output, unions are namespaced with the contract's scope prefix.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | union name |
| `discriminator` | `Symbol` | field that identifies the variant |

**Example**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
  variant tag: 'bank' do
    object do
      string :account_number
    end
  end
end
```

---

## Instance Methods

### #action_name

`#action_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L67)

**Returns**

`Symbol` — the current action name

---

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L75)

**Returns**

`Hash` — parsed and validated request body

---

### #invalid?

`#invalid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L551)

Returns whether the contract has validation issues.

**Returns**

`Boolean` — true if any validation issues

---

### #issues

`#issues`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L63)

**Returns**

Array&lt;[Issue](issue)&gt; — validation issues (empty if valid)

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L71)

**Returns**

`Hash` — parsed and validated query parameters

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L59)

**Returns**

[Adapter::Request](adapter-request) — the parsed and validated request

---

### #valid?

`#valid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L544)

Returns whether the contract passed validation.

**Returns**

`Boolean` — true if no validation issues

---
