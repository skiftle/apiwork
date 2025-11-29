# Contracts

Contracts define the input and output for each API action.

```ruby
class PostContract < Apiwork::Contract::Base
  schema!

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

## Naming Convention

Apiwork infers the contract from the controller name:

| Controller | Contract |
|-----------|----------|
| `Api::V1::PostsController` | `Api::V1::PostContract` |
| `Api::V1::CommentsController` | `Api::V1::CommentContract` |

The contract name is the singular form of the controller name.

## Connecting to Schema

Use `schema!` to connect the contract to its corresponding schema:

```ruby
class PostContract < Apiwork::Contract::Base
  schema!  # Connects to PostSchema
end
```

This enables automatic serialization of responses. See [Schemas](../04-schemas/01-introduction.md).

## Contract Parsing

When a request comes in, the contract:

1. Extracts query parameters and body
2. Coerces values to the declared types
3. Validates against the contract definition
4. Returns parsed data or validation issues

```ruby
contract = PostContract.new(
  query: params,
  body: request.body,
  action: :create
)

if contract.valid?
  contract.body  # Parsed and coerced data
else
  contract.issues  # Validation errors
end
```
