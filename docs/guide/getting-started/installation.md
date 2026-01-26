---
order: 2
---

# Installation

This guide covers installing Apiwork in a Rails application. After setup, you'll have the directory structure for contracts and schemas, plus generators for creating new resources.

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

Run the install generator to create the directory structure and mount Apiwork in your routes:

```bash
rails generate apiwork:install
```

This creates:

```text
app/
├── contracts/
│   └── application_contract.rb
└── representations/
    └── application_representation.rb
config/
└── apis/
```

These sit alongside your existing `app/controllers/` and `app/models/`. Your contracts and schemas inherit from these application-level base classes, just like controllers inherit from `ApplicationController`.

The generator also adds the following to your `config/routes.rb`:

```ruby
mount Apiwork => '/'
```

The final URL combines the mount point with each API's path — mounting at `/` with an API defined at `/api/v1` creates routes at `/api/v1/posts`.

## Generators

Apiwork provides generators for common files.

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
- Representations in `Api::V1::` (e.g. `Api::V1::PostRepresentation`)

::: tip
For a root-level API with no path prefix, use `rails generate apiwork:api /`. This creates `config/apis/root.rb`.
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

Creates a representation for a resource:

```bash
rails generate apiwork:schema api/v1/invoice
```

This generates:

```ruby
# app/representations/api/v1/invoice_representation.rb
module Api
  module V1
    class InvoiceRepresentation < ApplicationRepresentation
    end
  end
end
```

::: info
Contracts and representations follow the same namespace structure as your controllers. If your controller is `Api::V1::InvoicesController`, your contract is `Api::V1::InvoiceContract` and your representation is `Api::V1::InvoiceRepresentation`.
:::

## Next Steps

With Apiwork installed, you're ready to learn how it works.

- [Core Concepts](./core-concepts.md) — understand API definitions, representations, and contracts
- [Quick Start](./quick-start.md) — build a complete API with validation, filtering, and exports
