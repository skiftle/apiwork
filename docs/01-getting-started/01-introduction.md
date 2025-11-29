# Introduction

Apiwork is a contract-driven, schema-aware API framework for Rails.

It builds on the strengths Rails already gives you — especially ActiveRecord — and adds a clear structure around the API itself. You keep working the same way you normally do with controllers, models and resources. Apiwork just provides a clean place to describe how the API is supposed to behave.

## Why Contract-Driven?

A contract defines what an endpoint accepts and returns. That brings a few important benefits:

**Safety** — only the fields you’ve defined are allowed in.  
**Predictability** — requests and responses follow a clear structure.  
**Generated specs** — because the contract is explicit, Apiwork can generate OpenAPI, Zod schemas, TypeScript types and similar specs automatically. These are standard tools today for validation, documentation and typed clients, and Apiwork supports them out of the box.  
**Documentation that stays accurate** — since it’s based on the contract, it stays in sync without extra work.

In short, the contract becomes the single place where the API is described, which helps everything else fall into place.

```ruby
class PostContract < Apiwork::Contract::Base
  action :create do
    request do
      body do
        param :title, type: :string
        param :body, type: :string
      end
    end
    response { body PostSchema }
  end
end
```

Naming follows Rails conventions: `PostsController` automatically uses `PostContract` and `PostSchema`.

## Schemas (Optional, but Very Helpful)

Schemas are optional, but they match Rails well and remove a lot of duplication.  
When you use them, Apiwork can read information directly from your ActiveRecord models:

- column and database types
- enums
- associations
- nullability and constraints

This means the database — via ActiveRecord — acts as the underlying source of truth. Apiwork uses that information to enrich contracts, power adapters and improve generated specs. You’re free to define everything manually, but schemas save time and keep things consistent.

## Consolidation

One of the nice things about Apiwork is that it replaces several tools that are often combined in Rails apps. Instead of reaching for separate gems for serialization, documentation, filtering, pagination, validation and client type generation, Apiwork brings all of this together into a single system designed to work smoothly from end to end.

Contracts describe the rules.  
Schemas (when used) add extra structure.  
Adapters make the data actionable.  
And the API definition ties everything together.

The result is an API that feels consistent, predictable and easy to maintain — without juggling multiple libraries that each solve a small part of the problem.

## Works With Rails, Not Against It

Apiwork is a preparation layer. It validates and transforms input, then hands it off to Rails.

Your controller stays minimal:

```ruby
def create
  post = Post.create(contract.body[:post])
  respond_with post
end
```

The `contract.body[:post]` is already validated, coerced, and shaped for ActiveRecord. For writable associations, Apiwork transforms `comments` into `comments_attributes` — ready for Rails' `accepts_nested_attributes_for`. You set up Rails the normal way, and Apiwork prepares the data to match.

This means you keep using Rails the way you always have. Apiwork doesn't replace ActiveRecord validations, callbacks, or any other Rails feature. It prepares data so Rails can do what it does best.
