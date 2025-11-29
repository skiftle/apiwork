# Contracts

Contracts define the structure of each API action: what the request must look like and what the response will contain. They act as the formal description of how an endpoint behaves.

Every action that plans to receive a request or produce a response should have an action definition in its contract. The API definition declares _which_ actions exist, the controller implements the behaviour, and the contract specifies the shape of the request and response for those actions.

A minimal contract might look like this:

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

## Naming Convention

Apiwork infers the contract from the controller name:

| Controller                    | Contract                   |
| ----------------------------- | -------------------------- |
| `Api::V1::PostsController`    | `Api::V1::PostContract`    |
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

## How Contract Requirements Are Enforced

Apiwork ensures that both incoming and outgoing data adhere to the contract in a clear and unobtrusive way.

When a request comes in, a `before_action` in the controller hands the parameters over to the contract. The contract then extracts the query and body parameters, coerces the incoming values into the declared types, and validates them against the request definition. If everything matches, the controller action runs as usual and receives the data. If not, Apiwork returns a `ValidationError` with a detailed `errors` array describing exactly what failed.

Response handling works differently, since it is less critical for the request flow. After the controller finishes, Apiwork checks the response against the contract’s response definition. If something doesn’t match, the mismatch is logged in development mode so it can be fixed early. No error is ever returned to the client, and these checks are skipped entirely in production to avoid any performance impact.

This approach keeps incoming data strict and reliable—while still giving developers visibility into accidental response drift without affecting production behaviour.

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
