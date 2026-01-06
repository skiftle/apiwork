---
order: 2
---

# Installation

## Requirements

- Ruby 3.2 or higher
- Rails 8.0 or higher

## Add to Gemfile

```ruby
gem 'apiwork'
```

Then run:

```bash
bundle install
```

## Setup

Run the install generator to create the directory structure Apiwork expects:

```bash
rails generate apiwork:install
```

This creates:

```text
app/
├── contracts/
│   └── application_contract.rb
└── schemas/
    └── application_schema.rb
config/
└── apis/
```

These sit alongside your existing `app/controllers/` and `app/models/`. Your contracts and schemas inherit from these application-level base classes, just like controllers inherit from `ApplicationController`.

## Generators

Apiwork provides generators to scaffold the files you'll work with most.

### apiwork:api

Creates an API definition in `config/apis/`:

```bash
rails generate apiwork:api api/v1
```

This generates:

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
end
```

The path `/api/v1` determines both the mount point and the namespace. Apiwork expects:

- Controllers in `Api::V1::` (e.g. `Api::V1::PostsController`)
- Contracts in `Api::V1::` (e.g. `Api::V1::PostContract`)
- Schemas in `Api::V1::` (e.g. `Api::V1::PostSchema`)

::: tip
For a root-level API with no path prefix, use `rails generate apiwork:api /`
:::

### apiwork:contract

Creates a contract for a resource:

```bash
rails generate apiwork:contract api/v1/invoice
```

This generates:

```ruby
# app/contracts/api/v1/invoice_contract.rb
module Api
  module V1
    class InvoiceContract < ApplicationContract
    end
  end
end
```

### apiwork:schema

Creates a schema for a resource:

```bash
rails generate apiwork:schema api/v1/invoice
```

This generates:

```ruby
# app/schemas/api/v1/invoice_schema.rb
module Api
  module V1
    class InvoiceSchema < ApplicationSchema
    end
  end
end
```

::: info
Contracts and schemas follow the same namespace structure as your controllers. If your controller is `Api::V1::InvoicesController`, your contract is `Api::V1::InvoiceContract` and your schema is `Api::V1::InvoiceSchema`.
:::

## Next Steps

With Apiwork installed, you're ready to learn how it works.

- [Core Concepts](./core-concepts.md) — understand API definitions, schemas, and contracts
- [Quick Start](./quick-start.md) — build a complete API with validation, filtering, and exports
