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
# app/contracts/invoice_contract.rb
class InvoiceContract < Apiwork::Contract::Base
  action :create do
    request do
      body do
        param :invoice, type: :object, required: true do
          param :number, type: :string
          param :issued_on, type: :date
          param :notes, type: :string
          param :lines, type: :array do
            param :description, type: :string
            param :quantity, type: :integer
            param :price, type: :decimal
          end
        end
      end
    end

    response do
      body do
        param :id, type: :uuid
        param :number, type: :string
        param :issued_on, type: :date
        param :created_at, type: :datetime
      end
    end
  end
end
```

## Schemas (optional superpower)

Schemas are optional, but they fit naturally into Rails and eliminate a huge amount of manual work. While contracts alone can take you far — and offer a powerful, expressive way to define request and response shapes — relying only on contracts still means you’re hand-describing structures that already exist in your models. The real strength of Apiwork appears when schemas are introduced;

```ruby
# app/schemas/line_schema.rb
class LineSchema < Apiwork::Schema::Base
  attribute :id
  attribute :description, writable: true
  attribute :quantity, writable: true
  attribute :price, writable: true
end

# app/schemas/invoice_schema.rb
class InvoiceSchema < Apiwork::Schema::Base
  attribute :id
  attribute :created_at
  attribute :updated_at
  attribute :number, writable: true
  attribute :issued_on, writable: true
  attribute :notes, writable: true

  has_many :lines, writable: true, include: :always
end

# app/contracts/invoice_contract.rb
class InvoiceContract < Apiwork::Contract::Base
  schema!
end
```

The schema system maps your ActiveRecord models directly into Apiwork’s metadata, automatically pulling in column types, enums, associations and constraints. Instead of repeating what Rails already knows, Apiwork builds on it — wiring up filters, sorting, nested operations, pagination and type generation without extra definitions.
In short: contracts give you control, but schemas give you leverage. They turn your existing Rails models into fully typed, API-ready structures with almost no effort, and let Apiwork handle the rest.

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
  invoice = Invoice.create(contract.body[:invoice])
  respond_with invoice
end
```

`contract.body[:invoice]` is already validated, coerced and shaped for ActiveRecord.
For writable associations, Apiwork automatically maps `lines` to `lines_attributes`, ready for Rails' `accepts_nested_attributes_for`. You configure Rails as usual; Apiwork prepares the data to match.

Apiwork doesn't replace ActiveRecord validations, callbacks or any Rails functionality.  
It prepares clean, typed, predictable data so Rails can do what Rails is good at.
