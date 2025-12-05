---
order: 1
---

# Introduction

Contracts define what goes in and what comes out of each endpoint.

You declare the shape of requests and responses. Apiwork validates incoming data, rejects anything that doesn't match, and checks responses in development.

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

This says: the `create` action expects a request body with `title` and `body`, both strings.

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
5. If valid → controller receives clean data
6. If invalid → 422 with structured errors

**Response checking:**

- After your controller runs, Apiwork checks the response against the contract
- Mismatches are logged in development — you'll see them, fix them early
- No errors returned to clients, no checks in production

This keeps incoming data strict while giving you visibility into response drift.

## Manual Usage

You rarely need this, but contracts work standalone:

```ruby
contract = PostContract.new(
  query: params,
  body: request.body,
  action: :create
)

if contract.valid?
  contract.body   # Parsed, coerced data
else
  contract.issues # Validation errors
end
```
