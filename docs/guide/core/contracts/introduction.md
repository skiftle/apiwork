---
order: 1
---

# Introduction

Contracts define what goes in and what comes out of each resource action.

You declare the shape of requests and responses using [params](./params.md) and [types](../type-system/introduction.md). Apiwork validates incoming data, rejects anything that doesn't match, and logs response mismatches in development.

## A Minimal Contract

```ruby
class PostContract < Apiwork::Contract::Base
  action :create do
    request do
      body do
        param :title, type: :string
        param :body, type: :string
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

## Connecting to a Schema

Add `schema!` to connect the contract to its schema:

```ruby
class PostContract < Apiwork::Contract::Base
  schema!  # Connects to PostSchema
end
```

Now responses are serialized through the schema. See [Schemas](../schemas/introduction.md).

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

## Manual Usage

You rarely need this, but contracts work standalone:

```ruby
contract = PostContract.new(
  query: request.query_parameters.deep_symbolize_keys,
  body: request.request_parameters.deep_symbolize_keys,
  action: :create
)

if contract.valid?
  contract.body   # Parsed, coerced data
else
  contract.issues # Validation errors
end
```
