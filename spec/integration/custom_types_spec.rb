# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Types', type: :integration do
  describe 'API-level types (Base.type)' do
    it 'defines a reusable custom type' do
      api = Apiwork::API.define '/test/types' do
        type :address, description: 'A physical address' do
          param :street, type: :string
          param :city, type: :string
          param :zip, type: :string
        end
      end

      expect(api.type_system.types.key?(:address)).to be(true)
    end

    it 'type is available in introspection' do
      api = Apiwork::API.define '/test/types/introspect' do
        type :money, description: 'Monetary amount' do
          param :amount, type: :decimal
          param :currency, type: :string
        end
      end

      introspection = api.introspect
      expect(introspection.types).to have_key(:money)
    end

    it 'supports nested types' do
      api = Apiwork::API.define '/test/types/nested' do
        type :line_item do
          param :product, type: :string
          param :quantity, type: :integer
          param :price, type: :object do
            param :amount, type: :decimal
            param :currency, type: :string
          end
        end
      end

      expect(api.type_system.types.key?(:line_item)).to be(true)
    end

    it 'supports deprecated types' do
      api = Apiwork::API.define '/test/types/deprecated' do
        type :old_format, deprecated: true, description: 'Use new_format instead' do
          param :data, type: :string
        end
      end

      expect(api.type_system.types.key?(:old_format)).to be(true)
      expect(api.type_system.types[:old_format][:deprecated]).to be(true)
    end

    it 'supports type with example' do
      api = Apiwork::API.define '/test/types/example' do
        type :coordinates, description: 'GPS coordinates', example: { lat: 59.33, lng: 18.07 } do
          param :lat, type: :decimal
          param :lng, type: :decimal
        end
      end

      expect(api.type_system.types.key?(:coordinates)).to be(true)
      expect(api.type_system.types[:coordinates][:example]).to eq({ lat: 59.33, lng: 18.07 })
    end
  end

  describe 'API-level enums (Base.enum)' do
    it 'defines a reusable enumeration type' do
      api = Apiwork::API.define '/test/enums' do
        enum :status, values: %i[pending active completed]
      end

      expect(api.type_system.enums.key?(:status)).to be(true)
    end

    it 'enum is available in introspection' do
      api = Apiwork::API.define '/test/enums/introspect' do
        enum :priority, values: %i[low medium high critical]
      end

      introspection = api.introspect
      expect(introspection.enums).to have_key(:priority)
      expect(introspection.enums[:priority].values).to eq(%i[low medium high critical])
    end

    it 'supports enum with description' do
      api = Apiwork::API.define '/test/enums/description' do
        enum :payment_method,
             description: 'Supported payment methods',
             values: %i[credit_card bank_transfer paypal]
      end

      expect(api.type_system.enums.key?(:payment_method)).to be(true)
      expect(api.type_system.enums[:payment_method][:description]).to eq('Supported payment methods')
    end

    it 'supports enum with example' do
      api = Apiwork::API.define '/test/enums/example' do
        enum :day_of_week,
             example: :monday,
             values: %i[monday tuesday wednesday thursday friday saturday sunday]
      end

      expect(api.type_system.enums.key?(:day_of_week)).to be(true)
      expect(api.type_system.enums[:day_of_week][:example]).to eq(:monday)
    end

    it 'supports deprecated enums' do
      api = Apiwork::API.define '/test/enums/deprecated' do
        enum :old_status,
             deprecated: true,
             values: %i[on off]
      end

      expect(api.type_system.enums.key?(:old_status)).to be(true)
      expect(api.type_system.enums[:old_status][:deprecated]).to be(true)
    end

    it 'stores enum values correctly' do
      api = Apiwork::API.define '/test/enums/values' do
        enum :size, values: %i[small medium large]
      end

      expect(api.type_system.enum_values(:size)).to eq(%i[small medium large])
    end
  end

  describe 'API-level unions (Base.union)' do
    it 'defines a discriminated union type' do
      api = Apiwork::API.define '/test/unions' do
        union :notification, discriminator: :type do
          variant tag: :email, type: :object do
            param :address, type: :string
            param :subject, type: :string
          end

          variant tag: :sms, type: :object do
            param :phone_number, type: :string
            param :message, type: :string
          end
        end
      end

      expect(api.type_system.types.key?(:notification)).to be(true)
    end

    it 'union is available in introspection' do
      api = Apiwork::API.define '/test/unions/introspect' do
        union :payment, discriminator: :method do
          variant tag: :card, type: :object do
            param :card_number, type: :string
            param :expiry, type: :string
          end

          variant tag: :bank, type: :object do
            param :account_number, type: :string
            param :routing_number, type: :string
          end
        end
      end

      introspection = api.introspect
      expect(introspection.types).to have_key(:payment)
    end

    it 'stores union discriminator' do
      api = Apiwork::API.define '/test/unions/discriminator' do
        union :result, discriminator: :status do
          variant tag: :success, type: :object do
            param :data, type: :string
          end

          variant tag: :error, type: :object do
            param :message, type: :string
          end
        end
      end

      union_data = api.type_system.types[:result][:payload]
      expect(union_data[:discriminator]).to eq(:status)
    end
  end

  describe 'Types in existing dummy API' do
    it 'has API-level types defined' do
      api = Apiwork::API.find('/api/v1')

      # The dummy API defines error_detail and pagination_params types
      expect(api.type_system.types.key?(:error_detail)).to be(true)
      expect(api.type_system.types.key?(:pagination_params)).to be(true)
    end

    it 'has API-level enums defined' do
      api = Apiwork::API.find('/api/v1')

      # The dummy API defines sort_direction and post_status enums
      expect(api.type_system.enums.key?(:sort_direction)).to be(true)
      expect(api.type_system.enums.key?(:post_status)).to be(true)
    end

    it 'includes types in introspection' do
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      expect(introspection.types).to have_key(:error_detail)
      expect(introspection.types).to have_key(:pagination_params)
    end

    it 'includes enums in introspection' do
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      expect(introspection.enums).to have_key(:sort_direction)
      expect(introspection.enums).to have_key(:post_status)
    end

    it 'returns correct enum values' do
      api = Apiwork::API.find('/api/v1')

      sort_values = api.type_system.enum_values(:sort_direction)
      expect(sort_values).to eq(%i[asc desc])

      status_values = api.type_system.enum_values(:post_status)
      expect(status_values).to eq(%i[draft published archived])
    end
  end

  describe 'Type checking methods' do
    it 'type? returns true for existing types' do
      api = Apiwork::API.define '/test/type_check' do
        type :my_type do
          param :data, type: :string
        end
      end

      expect(api.type?(:my_type)).to be(true)
      expect(api.type?(:nonexistent)).to be(false)
    end

    it 'enum? returns true for existing enums' do
      api = Apiwork::API.define '/test/enum_check' do
        enum :my_enum, values: %i[a b c]
      end

      expect(api.enum?(:my_enum)).to be(true)
      expect(api.enum?(:nonexistent)).to be(false)
    end
  end

  describe 'Types in OpenAPI export' do
    it 'exports custom types as components/schemas' do
      openapi_json = Apiwork::Export.generate(:openapi, '/api/v1')
      openapi = JSON.parse(openapi_json)

      # Check that components/schemas exists
      expect(openapi).to have_key('components')
      expect(openapi['components']).to have_key('schemas')
    end
  end

  describe 'Types in TypeScript export' do
    it 'exports custom types as TypeScript types' do
      typescript = Apiwork::Export.generate(:typescript, '/api/v1')

      # TypeScript output should include type definitions
      expect(typescript).to be_a(String)
      expect(typescript).to include('export')
    end
  end
end
