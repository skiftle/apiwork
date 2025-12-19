---
order: 2
---

# Generators

Apiwork provides Rails generators for common setup tasks.

## Install

```bash
rails generate apiwork:install
```

Creates the base structure:

- `app/contracts/application_contract.rb`
- `app/schemas/application_schema.rb`
- `config/apis/`

```ruby
# app/contracts/application_contract.rb
class ApplicationContract < Apiwork::Contract::Base
  abstract!
end
```

```ruby
# app/schemas/application_schema.rb
class ApplicationSchema < Apiwork::Schema::Base
  abstract!
end
```

## API

```bash
rails generate apiwork:api api/v1
rails generate apiwork:api /
```

Creates an API definition:

- `config/apis/api_v1.rb`
- `config/apis/root.rb` (for `/`)

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
end
```

```ruby
# config/apis/root.rb
Apiwork::API.define '/' do
end
```

## Contract

```bash
rails generate apiwork:contract Post
rails generate apiwork:contract api/v1/post
```

Creates a contract class:

- `app/contracts/post_contract.rb`
- `app/contracts/api/v1/post_contract.rb`

```ruby
# app/contracts/post_contract.rb
class PostContract < ApplicationContract
end
```

```ruby
# app/contracts/api/v1/post_contract.rb
module Api
  module V1
    class PostContract < ApplicationContract
    end
  end
end
```

## Schema

```bash
rails generate apiwork:schema Post
rails generate apiwork:schema api/v1/post
```

Creates a schema class:

- `app/schemas/post_schema.rb`
- `app/schemas/api/v1/post_schema.rb`

```ruby
# app/schemas/post_schema.rb
class PostSchema < ApplicationSchema
end
```

```ruby
# app/schemas/api/v1/post_schema.rb
module Api
  module V1
    class PostSchema < ApplicationSchema
    end
  end
end
```
