---
order: 5
---

# Escape Hatches

Sometimes you need endpoints that don't fit Apiwork's contract-based model. Health checks, webhooks, or legacy endpoints might need different handling.

## Parallel Routes (Recommended)

The cleanest approach is to define routes outside Apiwork entirely. Rails merges route sets, so your own routes coexist with Apiwork's.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Your routes - no contracts, no validation
  get '/health', to: 'health#check'
  post '/webhooks/stripe', to: 'webhooks#stripe'

  # Apiwork handles the API
  mount Apiwork.routes => '/'
end
```

These controllers don't include `Apiwork::Controller` at all:

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

This keeps Apiwork concerns completely separate from non-API endpoints.

## Base Controllers

Base controllers that include `Apiwork::Controller` work automatically. Contract validation only runs when a matching resource exists in the API definition.

```ruby
module Api
  module V1
    class BaseController < ApplicationController
      include Apiwork::Controller

      rescue_from ActiveRecord::RecordNotFound do
        respond_with_error :not_found
      end
    end
  end
end
```

No special configuration needed. Child controllers with defined resources validate contracts normally.

## Skipping Contract Validation

For controllers that include `Apiwork::Controller` but should skip validation:

```ruby
class MySpecialController < ApplicationController
  include Apiwork::Controller

  # Skip for all actions
  skip_contract_validation!

  # Or skip for specific actions
  skip_contract_validation! only: [:health, :ping]

  # Or skip for all except specific actions
  skip_contract_validation! except: [:create, :update]
end
```

This is rarely needed. Consider parallel routes first.

### When to Use

| Scenario | Approach |
|----------|----------|
| Health checks, webhooks | Parallel routes |
| Base controller | Works automatically |
| Admin endpoints outside API | Parallel routes |
| Controller that must include Apiwork::Controller but has no resource | `skip_contract_validation!` |
