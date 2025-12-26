---
order: 5
---

# Escape Hatches

Not everything belongs in a contract. Health checks, webhooks, legacy endpoints — sometimes you need to bypass Apiwork.

## Parallel Routes (Recommended)

Define routes outside Apiwork entirely. Rails merges route sets, so your routes coexist with Apiwork's:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Your routes - no contracts, no validation
  get '/health', to: 'health#check'
  post '/webhooks/stripe', to: 'webhooks#stripe'

  # Apiwork handles the API
  mount Apiwork => '/'
end
```

These controllers don't include `Apiwork::Controller`:

```ruby
class HealthController < ApplicationController
  def check
    render json: { status: 'ok' }
  end
end

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    # Process webhook...
    head :ok
  end
end
```

Clean separation. Apiwork never sees these endpoints.

## Base Controllers

Base controllers with `Apiwork::Controller` work fine. Validation only runs when a matching resource exists in the API definition:

```ruby
module Api
  module V1
    class BaseController < ApplicationController
      include Apiwork::Controller

      rescue_from ActiveRecord::RecordNotFound do
        expose_error :not_found
      end
    end
  end
end
```

No special configuration needed.

## Skipping Validation

Rarely needed, but you can skip validation for specific actions:

```ruby
class MyController < ApplicationController
  include Apiwork::Controller

  # Skip for all actions
  skip_contract_validation!

  # Or specific actions only
  skip_contract_validation! only: [:health, :ping]

  # Or all except specific actions
  skip_contract_validation! except: [:create, :update]
end
```

Consider parallel routes first.

## When to Use What

| Scenario | Approach |
|----------|----------|
| Health checks, webhooks | Parallel routes |
| Base controller | Works automatically |
| Admin endpoints | Parallel routes |
| Must include Apiwork::Controller but has no resource | `skip_contract_validation!` |
