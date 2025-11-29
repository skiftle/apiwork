# Custom Types

Custom types are reusable object structures.

## Defining Types

```ruby
Apiwork::API.draw '/api/v1' do
  type :address do
    param :street, type: :string
    param :city, type: :string
    param :postal_code, type: :string
    param :country, type: :string
  end
end
```

## Using Types

Reference by name:

```ruby
param :shipping_address, type: :address
param :billing_address, type: :address
```

## Type Metadata

```ruby
type :address,
     description: 'Physical address',
     example: { street: '123 Main St', city: 'New York' },
     format: 'postal-address',
     deprecated: false do
  param :street, type: :string
  param :city, type: :string
end
```

## Arrays of Custom Types

```ruby
param :addresses, type: :array, of: :address
```

## Nested Types

Types can reference other types:

```ruby
Apiwork::API.draw '/api/v1' do
  type :address do
    param :street, type: :string
    param :city, type: :string
  end

  type :person do
    param :name, type: :string
    param :home_address, type: :address
    param :work_address, type: :address
  end
end
```

## Contract-Scoped Types

Define types inside a contract:

```ruby
class OrderContract < Apiwork::Contract::Base
  type :line_item do
    param :product_id, type: :integer
    param :quantity, type: :integer
    param :unit_price, type: :float
  end

  action :create do
    request do
      body do
        param :items, type: :array, of: :line_item
      end
    end
  end
end
```

The type is scoped as `:order_line_item`.
