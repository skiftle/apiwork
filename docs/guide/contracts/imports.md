---
order: 4
---

# Imports

Contracts can import types from other contracts.

::: tip
Use imports when contracts share types that don't belong at the API level.
:::

## Importing Types

```ruby
class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user

  action :create do
    request do
      body do
        reference :shipping_address, to: :user_address
      end
    end
  end
end
```

The `import` makes all types from `UserContract` available. The `as: :user` prefix is added to type names.

## How It Works

When an object is defined in a contract:

```ruby
class UserContract < Apiwork::Contract::Base
  object :address do
    string :street
    string :city
  end
end
```

When another contract imports with `as: :user`, the object becomes available as `:user_address` (prefix + original name).

## Multiple Imports

```ruby
class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user
  import ProductContract, as: :product

  action :create do
    request do
      body do
        reference :shipping_address, to: :user_address
        array :items do
          reference :product_line_item
        end
      end
    end
  end
end
```

## Importing Enums

Enums are imported the same way as types:

```ruby
class UserContract < Apiwork::Contract::Base
  enum :status, values: %w[active inactive]
end

class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user

  action :create do
    request do
      body do
        string :customer_status, enum: :user_status
      end
    end
  end
end
```

## Resolution Order

When resolving a type or enum, Apiwork checks in this order:

1. **Local scoped types** — defined in the current contract
2. **Global API types** — defined at the API level
3. **Imported types** — from imported contracts (searched in import order)

If a type name exists at multiple levels, the first match wins:

```ruby
class UserContract < Apiwork::Contract::Base
  object :address do
    string :street
    string :city
    string :country_code  # 3 params
  end
end

class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user

  # This local object shadows the imported one
  object :user_address do
    string :street
    string :city  # 2 params (no country_code)
  end

  action :show do
    response do
      body do
        reference :address, to: :user_address  # Uses local 2-param version
      end
    end
  end
end
```

::: warning
If a local type has the same name as an imported type (including the prefix), the local type takes precedence. This can be intentional (to override) or accidental (causing confusion).
:::

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

::: info
The circular import check occurs at type resolution time, not at import declaration time. The error appears when a type causes infinite recursion.
:::

#### See also

- [Contract::Base reference](../../reference/contract/base.md) — `import` method and options
