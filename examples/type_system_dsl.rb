# frozen_string_literal: true

# Example: Using the type system DSL to define API-global types and enums
# These are registered as unprefixed (scope: nil) and available across all contracts in the API

Apiwork::API.define '/api/v1' do
  # Define a global error type
  type :error do
    param :error, type: :string
    param :code, type: :integer
  end

  # Define a global sort direction enum
  enum :sort_direction, values: %i[asc desc]

  # Define a global pagination type
  type :page do
    param :number, type: :integer
    param :size, type: :integer
    param :total, type: :integer
  end

  # Define a global status enum
  enum :status, values: %i[active inactive pending]

  # These types are now available to all contracts in this API
  # They are unprefixed (e.g., :error, :sort_direction) not contract-scoped

  resources :posts do
    # PostContract can now use :error, :sort_direction, :page, :status
    # without needing to define them
  end
end
