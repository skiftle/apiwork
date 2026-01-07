# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeSystem Metadata' do
  describe 'Type metadata' do
    it 'stores and serializes type with description' do
      api = Apiwork::API.define '/api/test' do
        type :user_status, description: 'Current status of user account' do
          param :active, type: :boolean
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      expect(types[:user_status]).to include(description: 'Current status of user account')
    end

    it 'stores and serializes type with example' do
      api = Apiwork::API.define '/api/test' do
        type :address, example: { city: 'NYC', street: '123 Main St' } do
          param :street, type: :string
          param :city, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      expect(types[:address]).to include(example: { city: 'NYC', street: '123 Main St' })
    end

    it 'stores and serializes type with format' do
      api = Apiwork::API.define '/api/test' do
        type :email_field, format: 'email' do
          param :value, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      expect(types[:email_field]).to include(format: 'email')
    end

    it 'stores and serializes type with deprecated: true' do
      api = Apiwork::API.define '/api/test' do
        type :legacy_response, deprecated: true do
          param :old_field, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      expect(types[:legacy_response]).to include(deprecated: true)
    end

    it 'includes deprecated: false when not deprecated' do
      api = Apiwork::API.define '/api/test' do
        type :current_response, deprecated: false do
          param :field, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      expect(types[:current_response][:deprecated]).to be(false)
    end

    it 'stores and serializes type with all metadata fields' do
      api = Apiwork::API.define '/api/test' do
        type :payment_info,
             deprecated: true,
             description: 'Payment information structure',
             example: { amount: 100, currency: 'USD' },
             format: 'payment' do
          param :amount, type: :integer
          param :currency, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      expect(types[:payment_info]).to include(
        deprecated: true,
        description: 'Payment information structure',
        example: { amount: 100, currency: 'USD' },
        format: 'payment',
      )
    end

    it 'includes all metadata fields with defaults when not set' do
      api = Apiwork::API.define '/api/test' do
        type :simple_type do
          param :field, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      # All metadata fields are present with proper defaults
      expect(types[:simple_type][:description]).to be_nil
      expect(types[:simple_type][:example]).to be_nil
      expect(types[:simple_type][:format]).to be_nil
      expect(types[:simple_type][:deprecated]).to be(false)
    end

    it 'includes deprecated: false when explicitly set to false' do
      api = Apiwork::API.define '/api/test' do
        type :normal_type, deprecated: false do
          param :field, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      # deprecated is always present as a boolean
      expect(types[:normal_type][:deprecated]).to be(false)
    end

    it 'preserves empty string description' do
      api = Apiwork::API.define '/api/test' do
        type :empty_desc_type, description: '' do
          param :field, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      # Empty string is different from nil - should appear
      expect(types[:empty_desc_type]).to have_key(:description)
      expect(types[:empty_desc_type][:description]).to eq('')
    end
  end

  describe 'Enum metadata' do
    it 'stores and serializes enum with description' do
      api = Apiwork::API.define '/api/test' do
        enum :role, description: 'User role in the system', values: %w[admin user guest]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      expect(enums[:role][:description]).to eq('User role in the system')
    end

    it 'stores and serializes enum with example' do
      api = Apiwork::API.define '/api/test' do
        enum :priority, example: :medium, values: %i[low medium high]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      expect(enums[:priority][:example]).to eq(:medium)
    end

    it 'stores and serializes enum with deprecated: true' do
      api = Apiwork::API.define '/api/test' do
        enum :old_status, deprecated: true, values: %w[active inactive]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      expect(enums[:old_status][:deprecated]).to be true
    end

    it 'includes deprecated: false for enums when not deprecated' do
      api = Apiwork::API.define '/api/test' do
        enum :current_status, deprecated: false, values: %w[active inactive]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      # deprecated is always present as a boolean
      expect(enums[:current_status][:deprecated]).to be(false)
    end

    it 'stores and serializes enum with all metadata fields' do
      api = Apiwork::API.define '/api/test' do
        enum :color, deprecated: true, description: 'Available color options', example: 'red', values: %w[red green blue]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      expect(enums[:color]).to eq(
        deprecated: true,
        description: 'Available color options',
        example: 'red',
        values: %w[red green blue],
      )
    end

    it 'serializes enum as hash with values key' do
      api = Apiwork::API.define '/api/test' do
        enum :simple_enum, values: %i[a b c]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      # Enum should be a hash with :values key
      expect(enums[:simple_enum]).to be_a(Hash)
      expect(enums[:simple_enum]).to have_key(:values)
      expect(enums[:simple_enum][:values]).to eq(%i[a b c])
    end

    it 'includes all metadata fields with defaults when not set' do
      api = Apiwork::API.define '/api/test' do
        enum :minimal_enum, values: %i[x y z]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      # Values should be present
      expect(enums[:minimal_enum]).to have_key(:values)
      expect(enums[:minimal_enum][:values]).to eq(%i[x y z])

      # All metadata fields are present with proper defaults
      expect(enums[:minimal_enum][:description]).to be_nil
      expect(enums[:minimal_enum][:example]).to be_nil
      expect(enums[:minimal_enum][:deprecated]).to be(false)
    end

    it 'includes deprecated: false when explicitly set to false' do
      api = Apiwork::API.define '/api/test' do
        enum :normal_enum, deprecated: false, values: %i[a b]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      # deprecated is always present as a boolean
      expect(enums[:normal_enum][:deprecated]).to be(false)
    end

    it 'preserves empty string description' do
      api = Apiwork::API.define '/api/test' do
        enum :empty_desc_enum, description: '', values: %i[a b]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      # Empty string is different from nil - should appear
      expect(enums[:empty_desc_enum]).to have_key(:description)
      expect(enums[:empty_desc_enum][:description]).to eq('')
    end
  end

  describe 'Metadata isolation and scoping' do
    it 'keeps type metadata isolated between different APIs' do
      api1 = Apiwork::API.define '/api/v1' do
        type :shared_name, description: 'API v1 version' do
          param :field, type: :string
        end
      end

      api2 = Apiwork::API.define '/api/v2' do
        type :shared_name, description: 'API v2 version' do
          param :field, type: :integer
        end
      end

      types_v1 = Apiwork::Introspection::Dump::Type.new(api1).types
      types_v2 = Apiwork::Introspection::Dump::Type.new(api2).types

      expect(types_v1[:shared_name][:description]).to eq('API v1 version')
      expect(types_v2[:shared_name][:description]).to eq('API v2 version')
    end

    it 'keeps enum metadata isolated between different APIs' do
      api1 = Apiwork::API.define '/api/v1' do
        enum :status, description: 'V1 status', values: %w[active inactive]
      end

      api2 = Apiwork::API.define '/api/v2' do
        enum :status, description: 'V2 status', values: %w[pending approved]
      end

      enums_v1 = Apiwork::Introspection::Dump::Type.new(api1).enums
      enums_v2 = Apiwork::Introspection::Dump::Type.new(api2).enums

      expect(enums_v1[:status][:description]).to eq('V1 status')
      expect(enums_v1[:status][:values]).to eq(%w[active inactive])

      expect(enums_v2[:status][:description]).to eq('V2 status')
      expect(enums_v2[:status][:values]).to eq(%w[pending approved])
    end

    it 'preserves metadata on contract-scoped types' do
      api = Apiwork::API.define '/api/test' do
        # No resources, just for testing
      end

      Class.new(Apiwork::Contract::Base) do
        identifier :test_scoped

        class << self
          def api_class
            Apiwork::API.find('/api/test')
          end

          def resource_class
            nil
          end
        end

        type :scoped_type, description: 'Contract-scoped type with metadata' do
          param :field, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      # Should be qualified with contract identifier
      expect(types[:test_scoped_scoped_type]).to include(
        description: 'Contract-scoped type with metadata',
      )
    end

    it 'preserves metadata on contract-scoped enums' do
      api = Apiwork::API.define '/api/test' do
        # No resources, just for testing
      end

      Class.new(Apiwork::Contract::Base) do
        identifier :test_scoped

        class << self
          def api_class
            Apiwork::API.find('/api/test')
          end

          def resource_class
            nil
          end
        end

        enum :scoped_enum, description: 'Contract-scoped enum with metadata', values: %i[a b c]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      # Should be qualified with contract identifier
      expect(enums[:test_scoped_scoped_enum]).to include(
        description: 'Contract-scoped enum with metadata',
      )
    end
  end

  describe 'Edge cases' do
    it 'handles example value that does not match type schema' do
      api = Apiwork::API.define '/api/test' do
        type :user, example: 'not_a_hash' do
          param :name, type: :string
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      # Example should still be stored even if it doesn't match the schema
      expect(types[:user][:example]).to eq('not_a_hash')
    end

    it 'handles enum example that is not in values list' do
      api = Apiwork::API.define '/api/test' do
        enum :status, example: 'pending', values: %w[active inactive]
      end

      enums = Apiwork::Introspection::Dump::Type.new(api).enums

      # Example should still be stored even if it's not in the values
      expect(enums[:status][:example]).to eq('pending')
    end

    it 'handles format on non-string type gracefully' do
      api = Apiwork::API.define '/api/test' do
        type :weird_format, format: 'email' do
          param :count, type: :integer
        end
      end

      types = Apiwork::Introspection::Dump::Type.new(api).types

      # Format should be stored regardless of field types
      expect(types[:weird_format][:format]).to eq('email')
    end
  end
end
