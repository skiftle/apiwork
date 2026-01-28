---
order: 23
prev: false
next: false
---

# Contract::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

Base class for API contracts.

Contracts define request/response structure for a resource.
Link to a representation with [.representation](#representation) for automatic serialization.
Define actions with [.action](#action) for custom validation and response shapes.

**Example: Basic contract**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

**Example: With custom actions**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L346)

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

**Example: instance_eval style**

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

**Example: yield style**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  action :show do |action|
    action.request do |request|
      request.query do |query|
        query.string? :include
      end
    end
    action.response do |response|
      response.body do |body|
        body.uuid :id
      end
    end
  end
end
```

---

### .enum

`.enum(name, values: nil, description: nil, example: nil, deprecated: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L207)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L108)

The scope prefix for contract-scoped types.

Types, enums, and unions defined in this contract are namespaced
with this prefix in introspection output. For example, a type
`:address` becomes `:invoice_address` when identifier is `:invoice`.

If not set, prefix is derived from representation's root_key or class name.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L269)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L378)

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

`.object(name, description: nil, example: nil, format: nil, deprecated: false, representation_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L168)

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
| `representation_class` | `Class` | a [Representation::Base](representation-base) subclass for type inference |

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

### .representation

`.representation(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L133)

Links this contract to a representation class.

The representation defines the attributes and associations that
are serialized in responses. Adapters use the representation to
auto-generate request/response types.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a [Representation::Base](representation-base) subclass |

**Returns**

`void`

**See also**

- [Representation::Base](representation-base)

**Example**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation

  action :show
  action :create
end
```

---

### .union

`.union(name, discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L240)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L70)

**Returns**

`Symbol` — the current action name

---

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L78)

**Returns**

`Hash` — parsed and validated request body

---

### #invalid?

`#invalid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L556)

Returns whether the contract has validation issues.

**Returns**

`Boolean` — true if any validation issues

---

### #issues

`#issues`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L66)

**Returns**

Array&lt;[Issue](issue)&gt; — validation issues (empty if valid)

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L74)

**Returns**

`Hash` — parsed and validated query parameters

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L62)

**Returns**

[Adapter::Request](adapter-request) — the parsed and validated request

---

### #valid?

`#valid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L549)

Returns whether the contract passed validation.

**Returns**

`Boolean` — true if no validation issues

---
