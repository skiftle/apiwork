# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Descriptors Integration', type: :request do
  # Test API-level descriptors defined in config/apis/v1.rb
  # These should be available to all contracts in the API

  # Force reload of API configuration before tests
  # This ensures descriptors are registered even if registries were cleared
  before(:all) do
    load Rails.root.join('config/apis/v1.rb')
  end

  describe 'API-level descriptors' do
    it 'makes global types available via public introspect API' do
      # This is the public API that users will call
      introspection = Apiwork.introspect('/api/v1')

      # Global types should be present
      expect(introspection[:types]).to have_key(:error_detail)
      expect(introspection[:types][:error_detail]).to include(
        code: { type: :string, required: false, nullable: false },
        message: { type: :string, required: false, nullable: false },
        field: { type: :string, required: false, nullable: false }
      )

      expect(introspection[:types]).to have_key(:pagination_params)
      expect(introspection[:types][:pagination_params]).to include(
        page: { type: :integer, required: false, nullable: false },
        per_page: { type: :integer, required: false, nullable: false }
      )
    end

    it 'makes global types available in introspection' do
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      # Global types should be present
      expect(introspection[:types]).to have_key(:error_detail)
      expect(introspection[:types][:error_detail]).to include(
        code: { type: :string, required: false, nullable: false },
        message: { type: :string, required: false, nullable: false },
        field: { type: :string, required: false, nullable: false }
      )

      expect(introspection[:types]).to have_key(:pagination_params)
      expect(introspection[:types][:pagination_params]).to include(
        page: { type: :integer, required: false, nullable: false },
        per_page: { type: :integer, required: false, nullable: false }
      )
    end

    it 'makes global enums available via public introspect API' do
      # This is the public API that users will call
      introspection = Apiwork.introspect('/api/v1')

      expect(introspection[:enums]).to have_key(:sort_direction)
      expect(introspection[:enums][:sort_direction]).to match_array(%w[asc desc])

      expect(introspection[:enums]).to have_key(:post_status)
      expect(introspection[:enums][:post_status]).to match_array(%i[draft published archived])
    end

    it 'makes global enums available in introspection' do
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      expect(introspection[:enums]).to have_key(:sort_direction)
      expect(introspection[:enums][:sort_direction]).to match_array(%w[asc desc])

      expect(introspection[:enums]).to have_key(:post_status)
      expect(introspection[:enums][:post_status]).to match_array(%i[draft published archived])
    end

    it 'auto-generates enum filter types for global enums' do
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      # Filter types should be auto-generated
      expect(introspection[:types]).to have_key(:sort_direction_filter)
      expect(introspection[:types]).to have_key(:post_status_filter)

      # Verify it's a union type
      expect(introspection[:types][:sort_direction_filter][:type]).to eq(:union)
      expect(introspection[:types][:sort_direction_filter][:variants]).to be_an(Array)
      expect(introspection[:types][:sort_direction_filter][:variants].size).to eq(2)
    end
  end

  describe 'Contract-scoped descriptors' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        identifier :descriptor_test

        class << self
          def name
            'DescriptorTestContract'
          end

          def api_class
            Apiwork::API.find('/api/v1')
          end

          def resource_class
            nil
          end
        end

        # Contract-scoped custom type
        type :metadata do
          param :author, type: :string
          param :tags, type: :array, of: :string
        end

        # Contract-scoped enum
        enum :priority, %i[low medium high]

        # Contract-scoped union
        union :filter_value do
          variant type: :string
          variant type: :object do
            param :operator, type: :string
            param :value, type: :string
          end
        end

        action :create do
          input do
            param :metadata, type: :metadata
            param :priority, type: :priority
            param :filter, type: :filter_value
          end
        end
      end
    end

    it 'registers contract-scoped types with proper qualification' do
      contract_class # Trigger class definition
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      # Contract-scoped types should be prefixed with contract identifier
      expect(introspection[:types]).to have_key(:descriptor_test_metadata)
      expect(introspection[:types][:descriptor_test_metadata]).to include(
        author: { type: :string, required: false, nullable: false },
        tags: { type: :array, of: :string, required: false, nullable: false }
      )
    end

    it 'registers contract-scoped enums with proper qualification' do
      contract_class # Trigger class definition
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      expect(introspection[:enums]).to have_key(:descriptor_test_priority)
      expect(introspection[:enums][:descriptor_test_priority]).to match_array(%i[low medium high])
    end

    it 'registers contract-scoped unions with proper qualification' do
      contract_class # Trigger class definition
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      expect(introspection[:types]).to have_key(:descriptor_test_filter_value)
      expect(introspection[:types][:descriptor_test_filter_value][:type]).to eq(:union)
      expect(introspection[:types][:descriptor_test_filter_value][:variants].size).to eq(2)
    end

    it 'validates input against contract-scoped types' do
      action_definition = contract_class.action_definition(:create)

      # Valid input matching the custom type
      valid_input = {
        metadata: {
          author: 'John Doe',
          tags: %w[ruby rails]
        },
        priority: 'high',
        filter: 'simple string'
      }

      result = action_definition.input_definition.validate(valid_input)
      expect(result[:issues]).to be_empty
    end

    it 'validates input against contract-scoped enums' do
      action_definition = contract_class.action_definition(:create)

      # Valid enum value
      valid_input = {
        metadata: { author: 'Test' },
        priority: 'low', # Valid priority value
        filter: 'test'
      }

      result = action_definition.input_definition.validate(valid_input)
      expect(result[:issues]).to be_empty
      expect(result[:params][:priority]).to eq('low')
    end

    it 'validates input against contract-scoped union types' do
      action_definition = contract_class.action_definition(:create)

      # Valid union variant 1: string
      input_string = {
        metadata: { author: 'Test' },
        priority: 'low',
        filter: 'string value'
      }

      result = action_definition.input_definition.validate(input_string)
      expect(result[:issues]).to be_empty
      expect(result[:params][:filter]).to eq('string value')

      # Valid union variant 2: object
      input_object = {
        metadata: { author: 'Test' },
        priority: 'low',
        filter: {
          operator: 'equals',
          value: 'test'
        }
      }

      result = action_definition.input_definition.validate(input_object)
      expect(result[:issues]).to be_empty
      expect(result[:params][:filter]).to be_a(Hash)
      expect(result[:params][:filter][:operator]).to eq('equals')
    end
  end

  describe 'Mixed global and contract-scoped descriptors' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        identifier :mixed

        class << self
          def name
            'MixedContract'
          end

          def api_class
            Apiwork::API.find('/api/v1')
          end

          def resource_class
            nil
          end
        end

        # Use global enum from API-level descriptors
        # Use contract-scoped type
        type :search_options do
          param :direction, type: :sort_direction # Global enum
          param :limit, type: :integer
        end

        action :search do
          input do
            param :options, type: :search_options
          end
        end
      end
    end

    it 'allows using global enums in contract-scoped types' do
      action_definition = contract_class.action_definition(:search)

      valid_input = {
        options: {
          direction: 'asc', # Using global sort_direction enum
          limit: 10
        }
      }

      result = action_definition.input_definition.validate(valid_input)
      expect(result[:issues]).to be_empty
    end

    it 'uses global enum in nested type' do
      action_definition = contract_class.action_definition(:search)

      # Test with 'desc' direction
      input_desc = {
        options: {
          direction: 'desc', # Valid global enum value
          limit: 20
        }
      }

      result = action_definition.input_definition.validate(input_desc)
      expect(result[:issues]).to be_empty
      expect(result[:params][:options][:direction]).to eq('desc')
    end
  end

  describe 'Enum filter auto-generation' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        identifier :filter_test

        class << self
          def name
            'FilterTestContract'
          end

          def api_class
            Apiwork::API.find('/api/v1')
          end

          def resource_class
            nil
          end
        end

        enum :status, %i[active inactive pending]

        action :index do
          input do
            param :status_filter, type: :filter_test_status_filter
          end
        end
      end
    end

    it 'auto-generates filter type for contract-scoped enum' do
      contract_class # Trigger class definition
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      # Auto-generated filter should exist
      expect(introspection[:types]).to have_key(:filter_test_status_filter)
      filter_type = introspection[:types][:filter_test_status_filter]

      expect(filter_type[:type]).to eq(:union)
      expect(filter_type[:variants].size).to eq(2)
    end

    it 'validates enum value variant in filter' do
      action_definition = contract_class.action_definition(:index)

      # Direct enum value
      result = action_definition.input_definition.validate({ status_filter: 'active' })
      expect(result[:issues]).to be_empty
    end

    it 'validates object variant in filter' do
      action_definition = contract_class.action_definition(:index)

      # Object with eq field
      result = action_definition.input_definition.validate({
                                                             status_filter: { eq: 'active' }
                                                           })
      expect(result[:issues]).to be_empty

      # Object with in field (array)
      result = action_definition.input_definition.validate({
                                                             status_filter: { in: %w[active pending] }
                                                           })
      expect(result[:issues]).to be_empty
    end
  end

  describe 'Type resolution across contracts' do
    let(:shared_contract_class) do
      Class.new(Apiwork::Contract::Base) do
        identifier :shared_type

        class << self
          def name
            'SharedTypeContract'
          end

          def api_class
            Apiwork::API.find('/api/v1')
          end

          def resource_class
            nil
          end
        end

        type :address do
          param :street, type: :string
          param :city, type: :string
        end

        action :create do
          input do
            param :address, type: :address
          end
        end
      end
    end

    let(:using_contract_class) do
      Class.new(Apiwork::Contract::Base) do
        identifier :using_shared_type

        class << self
          def name
            'UsingSharedTypeContract'
          end

          def api_class
            Apiwork::API.find('/api/v1')
          end

          def resource_class
            nil
          end
        end

        action :update do
          input do
            # Try to use the address type from SharedTypeContract
            # This should NOT work - types are scoped to their contract
            # It would need to reference :shared_type_address (qualified name)
            param :location, type: :address
          end
        end
      end
    end

    it 'scopes types to their defining contract' do
      # SharedTypeContract should have access to :address
      action_def1 = shared_contract_class.action_definition(:create)
      result = action_def1.input_definition.validate({ address: { street: 'Main St', city: 'NYC' } })
      expect(result[:issues]).to be_empty
      expect(result[:params][:address][:street]).to eq('Main St')

      # Verify the type is registered with proper scoping
      api = Apiwork::API.find('/api/v1')
      introspection = api.introspect

      # Should have shared_type_address (qualified), not just address
      expect(introspection[:types]).to have_key(:shared_type_address)
      expect(introspection[:types][:shared_type_address]).to include(
        street: { type: :string, required: false, nullable: false },
        city: { type: :string, required: false, nullable: false }
      )
    end
  end
end
