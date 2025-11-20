# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Descriptors Integration', type: :request do
  # Test descriptor features using ONLY public APIs
  # The public API is: Apiwork::API.introspect(path)

  # Force reload of API configuration before tests
  before(:all) do
    load Rails.root.join('config/apis/v1.rb')
  end

  describe 'Public introspection API' do
    it 'returns descriptor information for an API' do
      result = Apiwork::API.introspect('/api/v1')

      expect(result).to be_a(Hash)
      expect(result).to have_key(:types)
      expect(result).to have_key(:enums)
      expect(result).to have_key(:resources)
    end

    it 'returns nil for non-existent API' do
      result = Apiwork::API.introspect('/api/nonexistent')
      expect(result).to be_nil
    end
  end

  describe 'API-level descriptors (global to API)' do
    it 'includes global types defined in descriptors block' do
      introspection = Apiwork::API.introspect('/api/v1')

      # error_detail type from config/apis/v1.rb
      expect(introspection[:types]).to have_key(:error_detail)
      expect(introspection[:types][:error_detail]).to include(
        type: :object,
        shape: {
          code: { type: :string, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil,
                  max: nil },
          message: { type: :string, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil,
                     max: nil },
          field: { type: :string, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil,
                   max: nil }
        },
        description: nil,
        example: nil,
        format: nil,
        deprecated: false
      )

      # pagination_params type from config/apis/v1.rb
      expect(introspection[:types]).to have_key(:pagination_params)
      expect(introspection[:types][:pagination_params]).to include(
        type: :object,
        shape: {
          page: { type: :integer, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil,
                  max: nil },
          per_page: { type: :integer, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil,
                      max: nil }
        },
        description: nil,
        example: nil,
        format: nil,
        deprecated: false
      )
    end

    it 'includes global enums defined in descriptors block' do
      introspection = Apiwork::API.introspect('/api/v1')

      # sort_direction enum from config/apis/v1.rb
      expect(introspection[:enums]).to have_key(:sort_direction)
      expect(introspection[:enums][:sort_direction][:values]).to match_array(%w[asc desc])

      # post_status enum from config/apis/v1.rb
      expect(introspection[:enums]).to have_key(:post_status)
      expect(introspection[:enums][:post_status][:values]).to match_array(%i[draft published archived])
    end

    it 'auto-generates filter types for global enums' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Auto-generated filter for sort_direction
      expect(introspection[:types]).to have_key(:sort_direction_filter)
      filter_type = introspection[:types][:sort_direction_filter]
      expect(filter_type[:type]).to eq(:union)
      expect(filter_type[:variants]).to be_an(Array)
      expect(filter_type[:variants].size).to eq(2)

      # Auto-generated filter for post_status
      expect(introspection[:types]).to have_key(:post_status_filter)
    end
  end

  describe 'Schema-based types and enums' do
    it 'includes enums from ActiveRecord models via schemas' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Account model has status enum
      expect(introspection[:enums]).to have_key(:account_status)
      expect(introspection[:enums][:account_status][:values]).to match_array(%w[active inactive archived])

      # Account model has first_day_of_week enum
      expect(introspection[:enums]).to have_key(:account_first_day_of_week)
      expect(introspection[:enums][:account_first_day_of_week][:values]).to match_array(
        %w[monday tuesday wednesday thursday friday saturday sunday]
      )
    end

    it 'auto-generates filter types for schema enums' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Filter for account_status
      expect(introspection[:types]).to have_key(:account_status_filter)
      filter = introspection[:types][:account_status_filter]
      expect(filter[:type]).to eq(:union)
      expect(filter[:variants].size).to eq(2)

      # Verify that enum filter uses scoped enum name (not unscoped)
      # Variant 1: the enum itself
      enum_variant = filter[:variants][0]
      expect(enum_variant[:type]).to eq(:account_status), 'First variant should reference scoped enum'

      # Variant 2: filter object with eq and in fields
      object_variant = filter[:variants][1]
      expect(object_variant[:type]).to eq(:object)
      expect(object_variant[:shape][:eq][:type]).to eq(:account_status),
                                                    'eq field should reference scoped enum'
      expect(object_variant[:shape][:in][:of]).to eq(:account_status),
                                                  'in array should reference scoped enum'
    end

    it 'generates enum filters with correct scoped enum references in both variants' do
      introspection = Apiwork::API.introspect('/api/v1')

      filter = introspection[:types][:account_status_filter]

      # Variant 1: The enum itself (scoped name)
      enum_variant = filter[:variants][0]
      expect(enum_variant[:type]).to eq(:account_status)
      expect(enum_variant).not_to include(:shape) # No shape for enum variant

      # Variant 2: Filter object with eq and in
      object_variant = filter[:variants][1]
      expect(object_variant[:type]).to eq(:object)
      expect(object_variant[:shape]).to have_key(:eq)
      expect(object_variant[:shape]).to have_key(:in)

      # Both fields must reference the SCOPED enum name
      expect(object_variant[:shape][:eq][:type]).to eq(:account_status)
      expect(object_variant[:shape][:in][:of]).to eq(:account_status)
      expect(object_variant[:shape][:in][:type]).to eq(:array)
    end

    it 'generates enum schema reference for union variants with enum field' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Find enum filter union type
      filter_type = introspection[:types][:account_status_filter]

      # First variant should have type reference (not inline enum)
      enum_variant = filter_type[:variants][0]
      expect(enum_variant[:type]).to eq(:account_status)
      expect(enum_variant).not_to have_key(:enum) # Type reference, not enum attribute

      # Object variant eq field should also be type reference
      eq_field = filter_type[:variants][1][:shape][:eq]
      expect(eq_field[:type]).to eq(:account_status)
      expect(eq_field).not_to have_key(:enum) # Type reference, not enum attribute
    end

    it 'does NOT use primitive filter types for enum attributes' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Enum filters should exist
      expect(introspection[:types]).to have_key(:account_status_filter)

      # The filter union should NOT reference string_filter
      filter = introspection[:types][:account_status_filter]
      filter[:variants].each do |variant|
        # No variant should reference :string_filter
        expect(variant[:type]).not_to eq(:string_filter)
      end
    end

    it 'includes schema attribute types in resource actions' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Verify accounts resource exists
      expect(introspection[:resources]).to have_key(:accounts)
      accounts = introspection[:resources][:accounts]

      # Should have actions
      expect(accounts[:actions]).to have_key(:show)
    end
  end

  describe 'JSON/JSONB column type inference' do
    it 'detects :json column type as :object in introspection' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Post schema should include metadata attribute
      post_type = introspection[:types][:post]
      expect(post_type).to be_present
      expect(post_type[:shape]).to have_key(:metadata)

      # metadata should be inferred as :object type (from :json column)
      metadata_field = post_type[:shape][:metadata]
      expect(metadata_field[:type]).to eq(:object)
    end
  end

  describe 'API isolation' do
    before(:all) do
      # Create a second API for isolation testing
      @second_api = Apiwork::API.draw '/api/v2' do
        descriptors do
          type :v2_specific_type do
            param :v2_field, type: :string
          end

          enum :v2_status, %i[pending approved rejected]
        end
      end
    end

    after(:all) do
      # Clean up
      Apiwork::API::Registry.unregister('/api/v2')
    end

    it 'keeps descriptors isolated between APIs' do
      v1_introspection = Apiwork::API.introspect('/api/v1')
      v2_introspection = Apiwork::API.introspect('/api/v2')

      # V1 should NOT have V2 descriptors
      expect(v1_introspection[:types]).not_to have_key(:v2_specific_type)
      expect(v1_introspection[:enums]).not_to have_key(:v2_status)

      # V2 should NOT have V1 descriptors
      expect(v2_introspection[:types]).not_to have_key(:error_detail)
      expect(v2_introspection[:types]).not_to have_key(:pagination_params)
      expect(v2_introspection[:enums]).not_to have_key(:sort_direction)
      expect(v2_introspection[:enums]).not_to have_key(:post_status)

      # V2 should HAVE its own descriptors
      expect(v2_introspection[:types]).to have_key(:v2_specific_type)
      expect(v2_introspection[:enums]).to have_key(:v2_status)
      expect(v2_introspection[:enums][:v2_status][:values]).to match_array(%i[pending approved rejected])
    end

    it 'includes schema types only in the API they belong to' do
      v1_introspection = Apiwork::API.introspect('/api/v1')
      v2_introspection = Apiwork::API.introspect('/api/v2')

      # V1 has account schema enums
      expect(v1_introspection[:enums]).to have_key(:account_status)

      # V2 does NOT have account schema enums (no resources defined)
      expect(v2_introspection[:enums]).not_to have_key(:account_status)
    end
  end

  describe 'Contract-scoped descriptors' do
    before(:all) do
      # Create an API with contract-scoped descriptors
      @contract_api = Apiwork::API.draw '/api/contracts' do
        # No resources, just contracts for testing
      end

      # Create a contract with scoped descriptors
      @test_contract = Class.new(Apiwork::Contract::Base) do
        identifier :test_contract

        class << self
          def name
            'TestContract'
          end

          def api_class
            Apiwork::API.find('/api/contracts')
          end

          def resource_class
            nil
          end
        end

        # Contract-scoped type
        type :metadata do
          param :author, type: :string
          param :version, type: :integer
        end

        # Contract-scoped enum
        enum :priority, %i[low medium high critical]

        # Contract-scoped union
        union :filter_value do
          variant type: :string
          variant type: :object do
            param :operator, type: :string
            param :value, type: :string
          end
        end

        action :process do
          input do
            param :metadata, type: :metadata
            param :priority, type: :priority
            param :filter, type: :filter_value
          end
        end
      end
    end

    after(:all) do
      Apiwork::API::Registry.unregister('/api/contracts')
    end

    it 'includes contract-scoped types with proper qualification' do
      introspection = Apiwork::API.introspect('/api/contracts')

      # Should be qualified with contract identifier
      expect(introspection[:types]).to have_key(:test_contract_metadata)
      expect(introspection[:types][:test_contract_metadata]).to include(
        type: :object,
        shape: {
          author: { type: :string, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil,
                    max: nil },
          version: { type: :integer, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil,
                     max: nil }
        },
        description: nil,
        example: nil,
        format: nil,
        deprecated: false
      )
    end

    it 'includes contract-scoped enums with proper qualification' do
      introspection = Apiwork::API.introspect('/api/contracts')

      expect(introspection[:enums]).to have_key(:test_contract_priority)
      expect(introspection[:enums][:test_contract_priority][:values]).to match_array(%i[low medium high critical])
    end

    it 'includes contract-scoped unions with proper qualification' do
      introspection = Apiwork::API.introspect('/api/contracts')

      expect(introspection[:types]).to have_key(:test_contract_filter_value)
      filter = introspection[:types][:test_contract_filter_value]
      expect(filter[:type]).to eq(:union)
      expect(filter[:variants].size).to eq(2)
    end

    it 'auto-generates filter types for contract-scoped enums' do
      introspection = Apiwork::API.introspect('/api/contracts')

      # Should have auto-generated filter
      expect(introspection[:types]).to have_key(:test_contract_priority_filter)
      filter = introspection[:types][:test_contract_priority_filter]
      expect(filter[:type]).to eq(:union)
      expect(filter[:variants].size).to eq(2)
    end
  end

  describe 'Mixed descriptor sources' do
    it 'combines global, schema, and contract-scoped descriptors in one API' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Should have ALL three types
      # 1. Global from descriptors block
      expect(introspection[:types]).to have_key(:error_detail)
      expect(introspection[:enums]).to have_key(:sort_direction)

      # 2. Schema-based enums
      expect(introspection[:enums]).to have_key(:account_status)

      # 3. Auto-generated filters for both global and schema enums
      expect(introspection[:types]).to have_key(:sort_direction_filter)
      expect(introspection[:types]).to have_key(:account_status_filter)
    end

    it 'properly qualifies types from different scopes' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Global types are unqualified
      expect(introspection[:types][:error_detail]).to be_present

      # Schema enums use schema/model name prefix
      expect(introspection[:enums][:account_status]).to be_present
      expect(introspection[:enums][:account_first_day_of_week]).to be_present
    end
  end

  describe 'Complete introspection structure' do
    it 'returns complete API introspection with all descriptor types' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Top-level structure
      expect(introspection).to have_key(:path)
      expect(introspection).to have_key(:info)
      expect(introspection).to have_key(:types)
      expect(introspection).to have_key(:enums)
      expect(introspection).to have_key(:resources)

      # Path is correct
      expect(introspection[:path]).to eq('/api/v1')

      # Info includes doc info
      expect(introspection[:info][:title]).to eq('Test API')

      # Types hash is not empty (has global + schema + filters)
      expect(introspection[:types]).not_to be_empty

      # Enums hash is not empty (has global + schema)
      expect(introspection[:enums]).not_to be_empty

      # Resources hash is not empty
      expect(introspection[:resources]).not_to be_empty
    end
  end

  describe 'Custom type and enum metadata in introspection' do
    before(:all) do
      @metadata_api = Apiwork::API.draw '/api/metadata_test' do
        descriptors do
          type :documented_type,
               description: 'A well-documented type',
               example: { value: 'example' },
               format: 'custom' do
            param :value, type: :string
          end

          enum :status_with_metadata,
               %w[active inactive],
               description: 'Status values with description',
               example: 'active',
               deprecated: false
        end
      end
    end

    after(:all) do
      Apiwork::API::Registry.unregister('/api/metadata_test')
    end

    it 'includes type metadata in introspection' do
      introspection = Apiwork::API.introspect('/api/metadata_test')

      expect(introspection[:types][:documented_type]).to include(
        description: 'A well-documented type',
        example: { value: 'example' },
        format: 'custom'
      )
    end

    it 'includes enum metadata in introspection' do
      introspection = Apiwork::API.introspect('/api/metadata_test')

      expect(introspection[:enums][:status_with_metadata]).to eq(
        values: %w[active inactive],
        description: 'Status values with description',
        example: 'active',
        deprecated: false
      )
    end

    it 'verifies enum structure is hash with metadata keys' do
      introspection = Apiwork::API.introspect('/api/metadata_test')

      enum_data = introspection[:enums][:status_with_metadata]

      expect(enum_data).to be_a(Hash)
      expect(enum_data).to have_key(:values)
      expect(enum_data).to have_key(:description)
      expect(enum_data).to have_key(:example)
      expect(enum_data).to have_key(:deprecated)
    end

    it 'shows deprecated: false explicitly when set' do
      introspection = Apiwork::API.introspect('/api/metadata_test')

      # deprecated: false should appear explicitly, not be omitted
      expect(introspection[:enums][:status_with_metadata][:deprecated]).to be false
    end

    it 'does not affect auto-generated filter types' do
      introspection = Apiwork::API.introspect('/api/metadata_test')

      # Filter type should be auto-generated
      expect(introspection[:types]).to have_key(:status_with_metadata_filter)

      # Filter type should be a union
      filter = introspection[:types][:status_with_metadata_filter]
      expect(filter[:type]).to eq(:union)
      expect(filter[:variants].size).to eq(2)
    end
  end
end
