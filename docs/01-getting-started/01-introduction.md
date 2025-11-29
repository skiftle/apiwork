# Introduction

Apiwork is a contract-driven, schema-aware API framework for Rails.

It builds on the parts of Rails that already work well — especially ActiveRecord — and adds a clear, consistent structure around the API layer. You continue to write controllers, models and resources the same way as always. Apiwork simply gives the API its own place, with explicit definitions for how it should behave.

## Why Contract-Driven?

A contract describes exactly what an endpoint accepts and returns. That gives you:

**Safety** — only defined fields are allowed in.  
**Predictability** — requests and responses follow a clear structure.  
**Generated specs** — because the contract is explicit, Apiwork can generate OpenAPI, Zod schemas, TypeScript types and other specs directly from it. These are widely used today for validation, documentation and typed clients, and Apiwork produces them automatically.  
**Documentation that stays correct** — since it's generated from the same contract the server uses, it stays in sync without effort.

The contract becomes the single place where the API is described — the backbone that the rest of the system uses.

Historically, Ruby and Rails have relied on flexibility and conventions. That works extremely well as long as everything stays inside Ruby — models, controllers and helpers can communicate freely without strict types. But an API is a boundary, and once data leaves Ruby, the dynamic nature becomes harder to rely on. Modern clients — often written in TypeScript, Swift, Kotlin or another service language — expect well-defined structures and predictable responses.

Apiwork aims to find a middle ground. It lets you keep the expressive Ruby code, the dynamic feel and the Rails conventions you’re used to, while still offering the structure that modern APIs require. Instead of bolting a static type system onto Ruby, Apiwork captures as much information as possible from Rails and ActiveRecord — column types, enums, associations, constraints — and uses that to describe the API clearly.

This makes it possible to stay in the Rails environment we enjoy, while still giving the API the structure and type-awareness modern clients expect — without the overhead of hand-written types or duplicated schema definitions.

```ruby
# app/contracts/post_contract.rb
class PostContract < Apiwork::Contract::Base
  action :create do
    request do
      body do
        param :title, type: :string
        param :body,  type: :string
      end
    end

    response { body PostSchema }
  end
end
```

Contracts follow Rails naming conventions:  
`PostsController` → `PostContract` → `PostSchema`.

## Schemas (Optional, but Very Helpful)

Schemas are optional, but they fit naturally into Rails and reduce a lot of repetition.  
When used, Apiwork can read structural information directly from your ActiveRecord models:

- database column types
- enum definitions
- associations
- nullability and constraints

In practice, the database — surfaced through ActiveRecord — becomes the underlying source of truth. Apiwork uses this to enrich contracts, power adapters and generate more complete specifications. You can define everything manually if you prefer, but schemas save time and keep things consistent with the actual data model.

## Consolidation

Rails developers often combine several libraries to handle serialization, documentation, filtering, pagination, validation and client type generation.  
Apiwork brings these concerns together into one coherent system.

Contracts define the rules.  
Schemas (when used) provide structure.  
Adapters turn that structure into actionable metadata.  
The API definition ties everything together.

The result is an API that is consistent, predictable and easy to maintain — without juggling multiple gems that each solve a small fragment of the problem.

## Works With Rails, Not Against It

Apiwork acts as a preparation layer. It validates and shapes the input, then hands it off to Rails.

Your controller remains minimal:

```ruby
def create
  post = Post.create(contract.body[:post])
  respond_with post
end
```

`contract.body[:post]` is already validated, coerced and shaped for ActiveRecord.  
For writable associations, Apiwork automatically maps `comments` to `comments_attributes`, ready for Rails’ `accepts_nested_attributes_for`. You configure Rails as usual; Apiwork prepares the data to match.

Apiwork doesn't replace ActiveRecord validations, callbacks or any Rails functionality.  
It prepares clean, typed, predictable data so Rails can do what Rails is good at.
