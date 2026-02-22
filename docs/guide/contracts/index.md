---
order: 2
---
# Contracts

A contract defines what a request accepts and what a response returns. It is the boundary between the outside world and your domain logic.

## What Contracts Do

Every contract enforces:

- **Validate requests** — coerce values into declared types, enforce constraints, reject invalid data with structured errors
- **Shape responses** — define what the API returns, checked in development
- **Describe the API** — the same definitions that execute at runtime are used to generate exports

Contracts are the most fundamental building block in Apiwork. They can be written entirely by hand.

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

The `create` action expects a request body with `title` and `body`, both strings. Invalid requests are rejected before your controller runs.

## Naming Convention

Apiwork resolves contracts from the controller name:

| Controller                    | Contract                   |
| ----------------------------- | -------------------------- |
| `Api::V1::PostsController`    | `Api::V1::PostContract`    |
| `Api::V1::CommentsController` | `Api::V1::CommentContract` |

Singular form of the controller name.

## Representation Mode

Connect a contract to a [representation](../representations/) to enter representation mode:

```ruby
class PostContract < Apiwork::Contract::Base
  representation PostRepresentation
end
```

In this mode, the contract is driven by its representation through an [adapter](../adapters/). Request bodies, response shapes, filter types, and sort options are derived automatically. All generated behavior remains fully customizable.

## Next Steps

- [Actions](./actions.md) — defining request and response shapes per action
- [Types](./types.md) — reusable objects, unions, enums, and fragments
- [Imports](./imports.md) — sharing types between contracts
- [Validation](./validation.md) — the request lifecycle and error handling

#### See also

- [Contract::Base reference](../../reference/contract/base.md) — all contract methods and options
