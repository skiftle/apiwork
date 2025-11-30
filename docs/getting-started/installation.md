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

## Directory Structure

Create the following directories in your Rails app:

```
app/
├── contracts/
└── schemas/
config/
└── apis/
```

These sit alongside your existing `app/controllers/` and `app/models/`.

## Define Your API

Create an API definition in `config/apis/`:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :posts
end
```

The path `/api/v1` determines both the mount point and the namespace. Apiwork expects:

- Controllers in `Api::V1::` (e.g. `Api::V1::PostsController`)
- Contracts in `Api::V1::` (e.g. `Api::V1::PostContract`)
- Schemas in `Api::V1::` (e.g. `Api::V1::PostSchema`)

## Include the Controller Concern

In your controllers, include `Apiwork::Controller::Concern`:

```ruby
# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    respond_with Post.all
  end

  def show
    respond_with Post.find(params[:id])
  end

  def create
    respond_with Post.create!(contract.body), status: :created
  end
end
```

## Verify It Works

Start your server and make a request:

```bash
rails server
curl http://localhost:3000/api/v1/posts
```

If you've enabled spec generation, you can also check:

```bash
curl http://localhost:3000/api/v1/.spec/openapi
```

## Next Steps

- [Architecture](./architecture.md) - understand how the pieces fit together
- [Quick Start](./quick-start.md) - build a complete endpoint
