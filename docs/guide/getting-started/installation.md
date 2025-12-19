---
order: 3
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

Run the install generator:

```bash
rails generate apiwork:install
```

This creates the directory structure Apiwork expects:

```plaintext
app/
├── contracts/
│   └── application_contract.rb
└── schemas/
    └── application_schema.rb
config/
└── apis/
```

These sit alongside your existing `app/controllers/` and `app/models/`.

## Define Your API

Run the API generator:

```bash
rails generate apiwork:api api/v1
```

Or create the file manually in `config/apis/`:

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
  resources :posts
end
```

The path `/api/v1` determines both the mount point and the namespace. Apiwork expects:

- Controllers in `Api::V1::` (e.g. `Api::V1::PostsController`)
- Contracts in `Api::V1::` (e.g. `Api::V1::PostContract`)
- Schemas in `Api::V1::` (e.g. `Api::V1::PostSchema`)

## Mount the Routes

Add Apiwork routes to your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Apiwork => '/'
end
```

This mounts all API definitions from `config/apis/` at the specified path. Each API's path (e.g. `/api/v1`) is combined with the mount path — mounting at `'/'` means `/api/v1/posts` while mounting at `'/backend'` would give `/backend/api/v1/posts`.

::: info
The mount path only affects URLs, not namespaces. Your controllers, contracts, and schemas always follow the namespace from the API definition (`Api::V1::` for `/api/v1`), regardless of where you mount the routes.
:::

## Include the Controller Module

In your controllers, include `Apiwork::Controller`:

```ruby
# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller

  def index
    respond Post.all
  end

  def show
    respond Post.find(params[:id])
  end

  def create
    respond Post.create!(contract.body), status: :created
  end
end
```

::: tip
For cleaner code, include `Apiwork::Controller` in an API base controller and have your API controllers inherit from it.
:::

## Verify It Works

Start your server and make a request:

```bash
rails server
curl http://localhost:3000/api/v1/posts
```

If you add `spec :openapi` to your API definition, you can also check the generated OpenAPI spec:

```bash
curl http://localhost:3000/api/v1/.spec/openapi
```

## Next Steps

- [Core Concepts](./core-concepts.md) — understand API definitions, contracts, and schemas
- [Quick Start](./quick-start.md) — build a complete endpoint
