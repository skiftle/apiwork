# Installation

Get Apiwork running in your Rails application.

## Requirements

- Ruby 2.7 or higher
- Rails 6.0 or higher
- PostgreSQL, MySQL, or SQLite (any ActiveRecord-supported database)

## Add to Gemfile

```ruby
gem 'apiwork'
```

Then install:

```bash
bundle install
```

## Configuration

Create an initializer at `config/initializers/apiwork.rb`:

```ruby
Apiwork.configure do |config|
  # Key transformation for JSON serialization
  config.serialize_key_transform = :camel      # camelCase for frontend
  config.deserialize_key_transform = :snake    # snake_case for Rails

  # Pagination defaults
  config.default_page_size = 20
  config.maximum_page_size = 100

  # Query defaults
  config.default_sort = { id: :asc }

  # Validation
  config.max_array_items = 1000

  # Association behavior
  config.auto_include_associations = false  # Don't auto-eager-load

end
```

## Directory structure

Create the following directories:

```bash
mkdir -p app/schemas
mkdir -p app/contracts
mkdir -p config/apis
```

Your structure should look like:

```
app/
  controllers/
    api/
      v1/
        posts_controller.rb
  models/
    post.rb
  schemas/
    api/
      v1/
        post_schema.rb
  contracts/
    api/
      v1/
        post_contract.rb
config/
  apis/
    v1.rb
```

## Mount your API

Create your API definition in `config/apis/v1.rb`:

```ruby
Apiwork::API.draw '/api/v1' do
  # Your routes go here
end
```

Apiwork automatically mounts this API. The path `/api/v1` determines:

- Mount point: `/api/v1`
- Namespace: `Api::V1`

## Optional: Generate helpers

You can create a generator for new resources. Add to `lib/tasks/generate.rake`:

```ruby
namespace :apiwork do
  desc 'Generate schema, contract, and controller for a resource'
  task :resource, [:name] => :environment do |t, args|
    name = args[:name]
    raise "Usage: rake apiwork:resource[resource_name]" unless name

    # Create schema
    schema_path = Rails.root.join("app/schemas/api/v1/#{name}_schema.rb")
    File.write(schema_path, <<~RUBY)
      class Api::V1::#{name.camelize}Schema < Apiwork::Schema::Base
        model #{name.camelize}

        attribute :id, filterable: true, sortable: true
        # Add more attributes here
      end
    RUBY

    # Create contract
    contract_path = Rails.root.join("app/contracts/api/v1/#{name}_contract.rb")
    File.write(contract_path, <<~RUBY)
      class Api::V1::#{name.camelize}Contract < Apiwork::Contract::Base
        schema Api::V1::#{name.camelize}Schema

        action :create do
          input do
            # Define input parameters
          end
        end

        action :update do
          input do
            # Define input parameters
          end
        end
      end
    RUBY

    # Create controller
    controller_path = Rails.root.join("app/controllers/api/v1/#{name.pluralize}_controller.rb")
    File.write(controller_path, <<~RUBY)
      class Api::V1::#{name.pluralize.camelize}Controller < ApplicationController
        include Apiwork::Controller::Concern

        def index
          respond_with query(#{name.camelize}.all)
        end

        def show
          respond_with #{name.camelize}.find(params[:id])
        end

        def create
          respond_with #{name.camelize}.create(action_params), status: :created
        end

        def update
          resource = #{name.camelize}.find(params[:id])
          resource.update(action_params)
          respond_with resource
        end

        def destroy
          resource = #{name.camelize}.find(params[:id])
          resource.destroy
          respond_with resource
        end
      end
    RUBY

    puts "Generated:"
    puts "  #{schema_path}"
    puts "  #{contract_path}"
    puts "  #{controller_path}"
    puts
    puts "Don't forget to add to config/apis/v1.rb:"
    puts "  resources :#{name.pluralize}"
  end
end
```

Usage:

```bash
rake apiwork:resource[post]
```

## Verify installation

Start your Rails server:

```bash
rails server
```

If you've defined any resources, verify they're accessible:

```bash
# Check if API responds
curl http://localhost:3000/api/v1/.schema/openapi

# Should return OpenAPI schema JSON
```

## What's next?

Now that Apiwork is installed:

1. **[Quick Start](./quick-start.md)** - Build your first endpoint
2. **[Core Concepts](./core-concepts.md)** - Understand the architecture
3. **[API Definition](../api-definition/introduction.md)** - Start defining routes

## Troubleshooting

### "Uninitialized constant Apiwork"

Make sure you've added `gem 'apiwork'` to your Gemfile and run `bundle install`.

### "No route matches"

Verify your API definition in `config/apis/v1.rb` is loaded. Rails should automatically load files in `config/apis/`.

### "Undefined method `respond_with`"

Make sure your controller includes `Apiwork::Controller::Concern`:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern
end
```

### Auto-loading issues

If classes aren't loading correctly, check your `config/application.rb`:

```ruby
config.autoload_paths += %W(#{config.root}/app/schemas #{config.root}/app/contracts)
```

### Schema endpoints not working

Make sure you've enabled schema generation in your API definition:

```ruby
Apiwork::API.draw '/api/v1' do
  schema :openapi
  schema :transport
  schema :zod

  resources :posts
end
```

## Configuration reference

See [Configuration](../reference/configuration.md) for all available options.
