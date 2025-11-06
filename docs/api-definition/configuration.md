# Configuration

Your API definition can expose schema endpoints and configure documentation.

## Schema endpoints

Enable schema generation for your frontend:

```ruby
Apiwork::API.draw '/api/v1' do
  schema :openapi     # GET /api/v1/.schema/openapi
  schema :transport   # GET /api/v1/.schema/transport
  schema :zod         # GET /api/v1/.schema/zod

  resources :posts
  resources :users
end
```

Now your API exposes three schema formats.

### OpenAPI schema

```ruby
schema :openapi
```

Creates: `GET /api/v1/.schema/openapi`

Returns a complete OpenAPI 3.1 specification:

```json
{
  "openapi": "3.1.0",
  "info": {
    "title": "API V1",
    "version": "1.0.0"
  },
  "paths": {
    "/api/v1/posts": {
      "get": {
        "operationId": "listPosts",
        "parameters": [...],
        "responses": {...}
      },
      "post": {...}
    }
  },
  "components": {
    "schemas": {...}
  }
}
```

Use this to:
- Generate API documentation (Swagger UI, Redoc)
- Generate client libraries (openapi-generator)
- Import into Postman or Insomnia
- Validate requests/responses

### Transport schema

```ruby
schema :transport
```

Creates: `GET /api/v1/.schema/transport`

Returns a TypeScript-friendly format:

```json
{
  "version": "1.0.0",
  "resources": {
    "posts": {
      "index": {
        "method": "GET",
        "path": "/api/v1/posts",
        "input": {...},
        "output": {...}
      },
      "show": {...}
    }
  }
}
```

Use this to:
- Generate TypeScript types
- Build type-safe API clients
- Power frontend code generators

See [Schema Generation: Transport](../schema-generation/transport.md) for details.

### Zod schema

```ruby
schema :zod
```

Creates: `GET /api/v1/.schema/zod`

Returns Zod validation schemas:

```typescript
import { z } from 'zod';

export const PostSchema = z.object({
  id: z.number(),
  title: z.string(),
  body: z.string(),
  published: z.boolean(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});

export const ListPostsInput = z.object({
  filter: z.object({
    published: z.boolean().optional(),
    title: z.string().optional(),
  }).optional(),
  sort: z.record(z.enum(['asc', 'desc'])).optional(),
  page: z.object({
    number: z.number().optional(),
    size: z.number().optional(),
  }).optional(),
});
```

Use this to:
- Validate API responses in your frontend
- Type-check API calls
- Generate forms with react-hook-form

See [Schema Generation: Zod](../schema-generation/zod.md) for details.

## Schema options

Customize schema endpoints:

```ruby
Apiwork::API.draw '/api/v1' do
  schema :openapi, path: 'openapi.json'
  schema :transport, path: 'types'
  schema :zod, path: 'validators'

  resources :posts
end
```

Now:
- `GET /api/v1/openapi.json`
- `GET /api/v1/types`
- `GET /api/v1/validators`

### Enable only in development

```ruby
Apiwork::API.draw '/api/v1' do
  if Rails.env.development?
    schema :openapi
    schema :transport
    schema :zod
  end

  resources :posts
end
```

Or configure globally in `config/initializers/apiwork.rb`:

```ruby
Apiwork.configure do |config|
  config.enable_schema_endpoints = !Rails.env.production?
end
```

## Documentation

Add API-level documentation using the `doc` block:

```ruby
Apiwork::API.draw '/api/v1' do
  doc do
    title "Blog API"
    version "1.0.0"
    description "A complete REST API for blog management"
  end

  schema :openapi

  resources :posts
  resources :users
end
```

This documentation appears in:
- OpenAPI schema
- Generated documentation
- API explorers (Swagger UI, Redoc)

See [Reference: Documentation](../reference/documentation.md) for all `doc` options.

### Resource and action documentation

Document individual resources and actions in your contracts:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema

  # Document custom actions
  action :publish do
    doc do
      summary "Publish a draft post"
      description "Changes post status from draft to published and sets published_at timestamp"
    end

    output do
      # ... action output definition
    end
  end
end
```

See [Contracts: Documentation](../contracts/documentation.md) for contract documentation.

## Multiple APIs in one app

You can define multiple independent APIs:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  schema :openapi
  resources :posts
end

# config/apis/v2.rb
Apiwork::API.draw '/api/v2' do
  schema :openapi
  resources :posts
  resources :articles  # New in v2
end

# config/apis/admin.rb
Apiwork::API.draw '/api/admin' do
  resources :users
  resources :posts
end
```

Each API is completely independent:
- Separate namespaces (`Api::V1`, `Api::V2`, `Api::Admin`)
- Separate controllers, contracts, schemas
- Separate OpenAPI specs

## Conditional resources

Load resources based on environment or feature flags:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
  resources :users

  # Only in development
  if Rails.env.development?
    resources :debug_logs
  end

  # Feature flag
  if ENV['FEATURE_COMMENTS'] == 'true'
    resources :comments
  end
end
```

## Global configuration

Configure Apiwork globally in `config/initializers/apiwork.rb`:

```ruby
Apiwork.configure do |config|
  # Key transformation
  config.serialize_key_transform = :camel      # camelCase in JSON
  config.deserialize_key_transform = :snake    # snake_case in Rails

  # Pagination
  config.default_page_size = 20
  config.maximum_page_size = 100

  # Sorting
  config.default_sort = { id: :asc }

  # Schema endpoints
  config.enable_schema_endpoints = !Rails.env.production?
end
```

See [Reference: Configuration](../reference/configuration.md) for all options.

## Security

### CORS

Configure CORS in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::API
  before_action :set_cors_headers

  private

  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, DELETE'
    headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
  end
end
```

Or use `rack-cors` gem for proper CORS support:

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :patch, :delete, :options]
  end
end
```

### Rate limiting

Apiwork doesn't provide rate limiting out of the box. Use Rails middleware:

```ruby
# Gemfile
gem 'rack-attack'
```

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  throttle('api/v1', limit: 100, period: 1.minute) do |req|
    if req.path.start_with?('/api/v1')
      req.ip
    end
  end
end
```

Or controller-level:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  before_action :check_rate_limit

  private

  def check_rate_limit
    # Your rate limiting logic
  end
end
```

### Authentication

Apiwork doesn't handle authentication - that's your Rails app's job.

Use any authentication system:

```ruby
class ApplicationController < ActionController::API
  include Apiwork::Controller::Concern

  before_action :authenticate_user!

  private

  def authenticate_user!
    # Your auth logic (JWT, Devise, etc.)
  end
end
```

Or per-controller:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  before_action :authenticate_user!, except: [:index, :show]

  # Public: index, show
  # Protected: create, update, destroy
end
```

## Organizing large APIs

As your API grows, organize by domain:

### Split into multiple files

Rails auto-loads files in `config/apis/`, so split your API:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  schema :openapi
  doc do
    title "Main API"
    version "1.0.0"
  end
end

# config/apis/v1/blog.rb
Apiwork::API.draw '/api/v1' do
  resources :posts
  resources :comments
end

# config/apis/v1/users.rb
Apiwork::API.draw '/api/v1' do
  resources :users
  resource :account
end
```

All these files merge into one `/api/v1` API.

### Use concerns

```ruby
Apiwork::API.draw '/api/v1' do
  concern :blog_routes do
    resources :posts do
      resources :comments
    end
    resources :tags
  end

  concern :user_routes do
    resources :users do
      resource :profile
    end
  end

  concerns :blog_routes
  concerns :user_routes
end
```

See [Advanced: Organizing](./advanced.md#organizing-large-routing-files) for more strategies.

## What Apiwork does NOT support

These features are **not supported** in Apiwork API configuration:

- ❌ `info` method - Use `doc` block instead
- ❌ `desc:` option on resources/actions - Document in contracts instead
- ❌ `defaults:` - No default parameters
- ❌ `tags:` - Not supported

For documentation, use the `doc` block at API level and contract-level documentation for resources and actions.

## Next steps

- **[Routing Options](./routing-options.md)** - All available options reference
- **[Advanced](./advanced.md)** - with_options and concerns
- **[Schema Generation](../schema-generation/introduction.md)** - Deep dive into schemas
- **[Reference: Configuration](../reference/configuration.md)** - All configuration options
