# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Descriptor Metadata' do
  before do
    Apiwork.reset_registries!
  end

  after do
    Apiwork.reset_registries!
  end

  describe 'Type metadata' do
    it 'stores and serializes type with description' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :user_status, description: 'Current status of user account' do
            param :active, type: :boolean
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:user_status]).to include(description: 'Current status of user account')
    end

    it 'stores and serializes type with example' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :address, example: { street: '123 Main St', city: 'NYC' } do
            param :street, type: :string
            param :city, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:address]).to include(example: { street: '123 Main St', city: 'NYC' })
    end

    it 'stores and serializes type with format' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :email_field, format: 'email' do
            param :value, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:email_field]).to include(format: 'email')
    end

    it 'stores and serializes type with deprecated: true' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :legacy_response, deprecated: true do
            param :old_field, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:legacy_response]).to include(deprecated: true)
    end

    it 'stores and serializes type with deprecated: false explicitly' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :current_response, deprecated: false do
            param :field, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:current_response]).to include(deprecated: false)
    end

    it 'stores and serializes type with all metadata fields' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :payment_info,
               description: 'Payment information structure',
               example: { amount: 100, currency: 'USD' },
               format: 'payment',
               deprecated: false do
            param :amount, type: :integer
            param :currency, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:payment_info]).to include(
        description: 'Payment information structure',
        example: { amount: 100, currency: 'USD' },
        format: 'payment',
        deprecated: false
      )
    end

    it 'includes all metadata fields even when nil' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :simple_type do
            param :field, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      # All metadata fields should always be present
      expect(types[:simple_type]).to have_key(:description)
      expect(types[:simple_type]).to have_key(:example)
      expect(types[:simple_type]).to have_key(:format)
      expect(types[:simple_type]).to have_key(:deprecated)

      # Values should be nil for unset fields, false for deprecated
      expect(types[:simple_type][:description]).to be_nil
      expect(types[:simple_type][:example]).to be_nil
      expect(types[:simple_type][:format]).to be_nil
      expect(types[:simple_type][:deprecated]).to be false
    end

    it 'includes deprecated: false explicitly even when false' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :normal_type, deprecated: false do
            param :field, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      # deprecated should appear as false, not be omitted
      expect(types[:normal_type]).to have_key(:deprecated)
      expect(types[:normal_type][:deprecated]).to be false
    end

    it 'preserves empty string description' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :empty_desc_type, description: '' do
            param :field, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      # Empty string is different from nil - should appear
      expect(types[:empty_desc_type]).to have_key(:description)
      expect(types[:empty_desc_type][:description]).to eq('')
    end
  end

  describe 'Enum metadata' do
    it 'stores and serializes enum with description' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :role, %w[admin user guest], description: 'User role in the system'
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      expect(enums[:role][:description]).to eq('User role in the system')
    end

    it 'stores and serializes enum with example' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :priority, %i[low medium high], example: :medium
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      expect(enums[:priority][:example]).to eq(:medium)
    end

    it 'stores and serializes enum with deprecated: true' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :old_status, %w[active inactive], deprecated: true
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      expect(enums[:old_status][:deprecated]).to be true
    end

    it 'stores and serializes enum with deprecated: false explicitly' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :current_status, %w[active inactive], deprecated: false
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      # deprecated should appear as false, not be omitted
      expect(enums[:current_status]).to have_key(:deprecated)
      expect(enums[:current_status][:deprecated]).to be false
    end

    it 'stores and serializes enum with all metadata fields' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :color,
               %w[red green blue],
               description: 'Available color options',
               example: 'red',
               deprecated: false
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      expect(enums[:color]).to eq(
        values: %w[red green blue],
        description: 'Available color options',
        example: 'red',
        deprecated: false
      )
    end

    it 'serializes enum as hash with values key' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :simple_enum, %i[a b c]
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      # Enum should be a hash with :values key
      expect(enums[:simple_enum]).to be_a(Hash)
      expect(enums[:simple_enum]).to have_key(:values)
      expect(enums[:simple_enum][:values]).to eq(%i[a b c])
    end

    it 'includes all metadata fields even when nil' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :minimal_enum, %i[x y z]
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      # All metadata fields should always be present
      expect(enums[:minimal_enum]).to have_key(:values)
      expect(enums[:minimal_enum]).to have_key(:description)
      expect(enums[:minimal_enum]).to have_key(:example)
      expect(enums[:minimal_enum]).to have_key(:deprecated)

      # Values should be the array, others nil except deprecated (false)
      expect(enums[:minimal_enum][:values]).to eq(%i[x y z])
      expect(enums[:minimal_enum][:description]).to be_nil
      expect(enums[:minimal_enum][:example]).to be_nil
      expect(enums[:minimal_enum][:deprecated]).to be false
    end

    it 'includes deprecated: false explicitly when set' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :normal_enum, %i[a b], deprecated: false
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      # deprecated should appear as false when explicitly set
      expect(enums[:normal_enum]).to have_key(:deprecated)
      expect(enums[:normal_enum][:deprecated]).to be false
    end

    it 'preserves empty string description' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :empty_desc_enum, %i[a b], description: ''
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      # Empty string is different from nil - should appear
      expect(enums[:empty_desc_enum]).to have_key(:description)
      expect(enums[:empty_desc_enum][:description]).to eq('')
    end
  end

  describe 'Metadata isolation and scoping' do
    it 'keeps type metadata isolated between different APIs' do
      api1 = Apiwork::API.draw '/api/v1' do
        descriptors do
          type :shared_name, description: 'API v1 version' do
            param :field, type: :string
          end
        end
      end

      api2 = Apiwork::API.draw '/api/v2' do
        descriptors do
          type :shared_name, description: 'API v2 version' do
            param :field, type: :integer
          end
        end
      end

      types_v1 = Apiwork::Contract::Descriptor::Registry.types(api1)
      types_v2 = Apiwork::Contract::Descriptor::Registry.types(api2)

      expect(types_v1[:shared_name][:description]).to eq('API v1 version')
      expect(types_v2[:shared_name][:description]).to eq('API v2 version')

      # Clean up
      Apiwork::API::Registry.unregister('/api/v1')
      Apiwork::API::Registry.unregister('/api/v2')
    end

    it 'keeps enum metadata isolated between different APIs' do
      api1 = Apiwork::API.draw '/api/v1' do
        descriptors do
          enum :status, %w[active inactive], description: 'V1 status'
        end
      end

      api2 = Apiwork::API.draw '/api/v2' do
        descriptors do
          enum :status, %w[pending approved], description: 'V2 status'
        end
      end

      enums_v1 = Apiwork::Contract::Descriptor::Registry.enums(api1)
      enums_v2 = Apiwork::Contract::Descriptor::Registry.enums(api2)

      expect(enums_v1[:status][:description]).to eq('V1 status')
      expect(enums_v1[:status][:values]).to eq(%w[active inactive])

      expect(enums_v2[:status][:description]).to eq('V2 status')
      expect(enums_v2[:status][:values]).to eq(%w[pending approved])

      # Clean up
      Apiwork::API::Registry.unregister('/api/v1')
      Apiwork::API::Registry.unregister('/api/v2')
    end

    it 'preserves metadata on contract-scoped types' do
      api = Apiwork::API.draw '/api/test' do
        # No resources, just for testing
      end

      Class.new(Apiwork::Contract::Base) do
        def self.name; 'TestTest_contractContract' end

        class << self
          def name
            'TestScopedContract'
          end

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

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      # Should be qualified with contract identifier
      expect(types[:test_scoped_scoped_type]).to include(
        description: 'Contract-scoped type with metadata'
      )

      # Clean up
      Apiwork::API::Registry.unregister('/api/test')
    end

    it 'preserves metadata on contract-scoped enums' do
      api = Apiwork::API.draw '/api/test' do
        # No resources, just for testing
      end

      Class.new(Apiwork::Contract::Base) do
        def self.name; 'TestTest_contractContract' end

        class << self
          def name
            'TestScopedContract'
          end

          def api_class
            Apiwork::API.find('/api/test')
          end

          def resource_class
            nil
          end
        end

        enum :scoped_enum, %i[a b c], description: 'Contract-scoped enum with metadata'
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      # Should be qualified with contract identifier
      expect(enums[:test_scoped_scoped_enum]).to include(
        description: 'Contract-scoped enum with metadata'
      )

      # Clean up
      Apiwork::API::Registry.unregister('/api/test')
    end
  end

  describe 'Edge cases' do
    it 'handles example value that does not match type schema' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :user, example: 'not_a_hash' do
            param :name, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      # Example should still be stored even if it doesn't match the schema
      expect(types[:user][:example]).to eq('not_a_hash')
    end

    it 'handles enum example that is not in values list' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :status, %w[active inactive], example: 'pending'
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      # Example should still be stored even if it's not in the values
      expect(enums[:status][:example]).to eq('pending')
    end

    it 'handles format on non-string type gracefully' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :weird_format, format: 'email' do
            param :count, type: :integer
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      # Format should be stored regardless of field types
      expect(types[:weird_format][:format]).to eq('email')
    end
  end
end
