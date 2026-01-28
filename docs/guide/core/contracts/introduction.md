---
order: 1
---

# Introduction

Contracts define the data structures at your API boundary.

You declare shapes using [types](../types/introduction.md). At runtime, Apiwork validates incoming requests against these definitions — coercing values into declared types, enforcing constraints, and rejecting invalid data.

## A Minimal Contract

```ruby
class PostContract < Apiwork::Contract::Base
  action :create do
    request do
      body do
        string :title
        string :body
      end
    end
  end
end
```

The `create` action expects a request body with `title` and `body`, both strings.

## Automatic Contract Creation

Not every representation needs an explicit contract. When Apiwork encounters a representation without a matching contract — through an association or STI variant — it creates one automatically.

```ruby
class OrderRepresentation < Apiwork::Representation::Base
  has_many :lines  # LineRepresentation exists, but no LineContract
end
```

Apiwork generates a contract for `LineRepresentation` on the fly. You only need to create a contract if you have an endpoint for the resource or need to customize the generated types.

## Naming Convention

Apiwork finds the contract from the controller name:

| Controller                    | Contract                   |
| ----------------------------- | -------------------------- |
| `Api::V1::PostsController`    | `Api::V1::PostContract`    |
| `Api::V1::CommentsController` | `Api::V1::CommentContract` |

Singular form of the controller name.

## Connecting to a Representation

Add `representation` to connect the contract to its representation:

```ruby
class PostContract < Apiwork::Contract::Base
  representation PostRepresentation
end
```

When a contract is connected to a representation, that contract enters representation mode.

In representation mode, the contract is driven by its representation through an adapter. The adapter interprets the representation and defines how resource actions, requests, and responses are derived from it.

The adapter implements the API conventions and enforces consistent behavior across the entire API.

The built-in adapter provides a complete REST API runtime out of the box. For each resource defined in your API definitions, it automatically generates the corresponding resource actions and derives their behavior from the representation as the source of truth.

All generated behavior remains fully customizable. You can override individual actions, replace them entirely, or extend them by merging additional behavior on top.

Now responses are serialized through the representation. See [Representations](../representations/introduction.md).

## Sharing Types Between Contracts

Not every domain concept needs an endpoint. An `Address` might only appear nested inside orders or users. A `LineItem` might be used across invoices and quotes.

These concepts still benefit from typed definitions. Define them in a contract:

```ruby
class AddressContract < Apiwork::Contract::Base
  object :address do
    string :street
    string :city
    string :postal_code
    string :country
  end
end
```

Then [import](./imports.md) where needed:

```ruby
class OrderContract < Apiwork::Contract::Base
  import AddressContract, as: :address

  action :create do
    request do
      body do
        reference :shipping_address, to: :address
        reference :billing_address, to: :address
      end
    end
  end
end
```

`AddressContract` has no endpoint — it exists purely to define the `Address` type.

`OrderContract` imports it and references the type in its actions.

::: info Import prefix
Imported types are prefixed with the `as:` name. An `:address` type from `as: :address` becomes just `:address`. Other types like `:details` would become `:address_details`.
:::

## What Happens at Runtime

**Request validation:**

1. Request comes in
2. Contract extracts query and body params
3. Values are coerced to declared types
4. Validation runs against the contract
5. If valid, controller receives clean data
6. If invalid, returns 400 with structured errors

**Response checking:**

- After your controller runs, Apiwork checks the response against the contract
- Mismatches are logged to Rails logger in development
- No errors returned to clients, no checks in production

::: info Strict in, lenient out
Request validation is strict: invalid data returns 400 Bad Request. Response checking is lenient: mismatches are logged but never break your API.
:::

#### See also

- [Contract::Base reference](../../../reference/contract-base.md) — all contract methods and options
