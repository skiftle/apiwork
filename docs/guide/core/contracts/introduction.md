---
order: 1
---

# Introduction

Contracts define what goes in and what comes out of each resource action.

Resource actions are defined by your [API definitions](../api-definitions/introduction.md). For example, a `resources :posts` declaration exposes the standard CRUD actions (`index`, `show`, `create`, `update`, `destroy`), each of which can be described and enforced by a contract.

You declare the shape of requests and responses using [types](../types/introduction.md). At runtime, Apiwork executes these contracts as a typed boundary: coercing input values into their declared types (booleans, numbers, dates, datetimes, times, decimals, enums, and more), validating constraints, rejecting invalid data, and logging response mismatches in development.

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
