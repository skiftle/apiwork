# Imports

Contracts can import types from other contracts.

## Importing Types

```ruby
class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user

  action :create do
    request do
      body do
        param :shipping_address, type: :user_address
      end
    end
  end
end
```

The `import` makes all types defined in `UserContract` available under the `:user` prefix.

## How It Works

When you define a type in a contract:

```ruby
class UserContract < Apiwork::Contract::Base
  type :address do
    param :street, type: :string
    param :city, type: :string
  end
end
```

The type is scoped to that contract as `:user_address`.

When another contract imports it:

```ruby
import UserContract, as: :user
```

The type becomes available as `:user_address` in the importing contract.

## Multiple Imports

```ruby
class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user
  import ProductContract, as: :product

  action :create do
    request do
      body do
        param :shipping_address, type: :user_address
        param :items, type: :array, of: :product_line_item
      end
    end
  end
end
```

## Circular Import Protection

Apiwork detects and prevents circular imports:

```ruby
# This would raise ConfigurationError
class A < Apiwork::Contract::Base
  import B, as: :b
end

class B < Apiwork::Contract::Base
  import A, as: :a  # Error: Circular import detected
end
```
