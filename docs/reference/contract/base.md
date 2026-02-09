---
order: 40
prev: false
next: false
---

# Base

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

`Boolean`

---

### .action

`.action(action_name, replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L285)

Defines an action on this contract.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `action_name` | `Symbol` |  | :index, :show, :create, :update, :destroy, or custom |
| `replace` | `Boolean` | `false` |  |

**Returns**

[Contract::Action](/reference/contract/action/)

**Yields** [Contract::Action](/reference/contract/action/)

**Example**

```ruby
action :show do
  request do
    query do
      string? :include
    end
  end
end
```

---

### .enum

`.enum(name, values: nil, description: nil, example: nil, deprecated: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L193)

Defines an enum scoped to this contract.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  |  |
| `values` | `Array<String>`, `nil` | `nil` |  |
| `description` | `String`, `nil` | `nil` |  |
| `example` | `String`, `nil` | `nil` |  |
| `deprecated` | `Boolean` | `false` |  |

**Returns**

`void`

**Example**

```ruby
enum :status, values: %w[draft sent paid]
```

---

### .identifier

`.identifier(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L112)

Prefixes types, enums, and unions in introspection output.

Must be unique within the API. Derived from the contract class
name when not set (e.g., `RecurringInvoiceContract` becomes
`recurring_invoice`).

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Symbol`, `String`, `nil` | `nil` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  identifier :billing

  object :address do
    string :street
  end
  # In introspection: :address becomes :billing_address
end
```

---

### .import

`.import(contract_class, as:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L237)

Imports types from another contract for reuse.

Imported types are accessed with a prefix matching the alias.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `contract_class` | `Class<Contract::Base>` |  |  |
| `as` | `Symbol` |  | alias prefix |

**Returns**

`void`

**Example**

```ruby
import UserContract, as: :user
# UserContract's :address becomes :user_address
```

---

### .introspect

`.introspect(expand: false, locale: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L309)

Returns introspection data for this contract.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `locale` | `Symbol`, `nil` | `nil` |  |
| `expand` | `Boolean` | `false` |  |

**Returns**

`Hash`

**Example**

```ruby
InvoiceContract.introspect
```

---

### .object

`.object(name, description: nil, example: nil, format: nil, deprecated: false, representation_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L160)

Defines a reusable object type scoped to this contract.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  |  |
| `description` | `String`, `nil` | `nil` |  |
| `example` | `Object`, `nil` | `nil` |  |
| `format` | `String`, `nil` | `nil` |  |
| `deprecated` | `Boolean` | `false` |  |
| `representation_class` | `Class<Representation::Base>`, `nil` | `nil` |  |

**Returns**

`void`

**Yields** [API::Object](/reference/api/object)

**Example**

```ruby
object :item do
  string :description
  decimal :amount
end
```

---

### .representation

`.representation(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L133)

Sets the representation class for this contract.

Adapters use the representation to auto-generate request/response
types. Use [.representation_class](#representation-class) to retrieve.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Representation::Base>` |  |  |

**Returns**

`void`

**See also**

- [.representation_class](#representation-class)

**Example**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

---

### .representation_class

`.representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L347)

The representation class for this contract.

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;, `nil`

**See also**

- [.representation](#representation)

---

### .union

`.union(name, discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L219)

Defines a discriminated union type scoped to this contract.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  |  |
| `discriminator` | `Symbol`, `nil` | `nil` |  |

**Returns**

`void`

**Yields** [API::Union](/reference/api/union)

**Example**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
end
```

---

## Instance Methods

### #action_name

`#action_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L76)

The action name for this contract.

**Returns**

`Symbol`

---

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L90)

The body for this contract.

**Returns**

`Hash`

**See also**

- [Request#body](/reference/request#body)

---

### #invalid?

`#invalid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L473)

Whether this contract is invalid.

**Returns**

`Boolean`

---

### #issues

`#issues`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L70)

The issues for this contract.

**Returns**

Array&lt;[Issue](/reference/issue)&gt;

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L83)

The query for this contract.

**Returns**

`Hash`

**See also**

- [Request#query](/reference/request#query)

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L64)

The request for this contract.

**Returns**

[Request](/reference/request)

---

### #valid?

`#valid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L465)

Whether this contract is valid.

**Returns**

`Boolean`

---
