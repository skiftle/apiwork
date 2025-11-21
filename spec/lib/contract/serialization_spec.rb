# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract Serialization' do
  describe 'Definition#as_json' do
    # Shared metadata fields that are always present
    let(:default_metadata) do
      {
        description: nil,
        example: nil,
        format: nil,
        deprecated: false,
        min: nil,
        max: nil
      }
    end

    it 'serializes simple params' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :create do
          input do
            param :title, type: :string, required: true
            param :published, type: :boolean, required: false, default: false
          end
        end
      end

      definition = contract_class.action_definition(:create).merged_input_definition
      json = definition.as_json

      expect(json).to eq({
                           title: {
                             nullable: false,
                             required: true,
                             type: :string,
                             **default_metadata
                           },
                           published: {
                             default: false,
                             nullable: false,
                             required: false,
                             type: :boolean,
                             **default_metadata
                           }
                         })
    end

    it 'serializes object with shape' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :create do
          input do
            param :post, type: :object, required: true do
              param :title, type: :string, required: true
              param :body, type: :string, required: false
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).merged_input_definition
      json = definition.as_json

      expect(json).to eq({
                           post: {
                             nullable: false,
                             required: true,
                             shape: {
                               title: {
                                 nullable: false,
                                 required: true,
                                 type: :string,
                                 description: nil,
                                 example: nil,
                                 format: nil,
                                 deprecated: false,
                                 min: nil,
                                 max: nil
                               },
                               body: {
                                 nullable: false,
                                 required: false,
                                 type: :string,
                                 description: nil,
                                 example: nil,
                                 format: nil,
                                 deprecated: false,
                                 min: nil,
                                 max: nil
                               }
                             },
                             type: :object,
                             description: nil,
                             example: nil,
                             format: nil,
                             deprecated: false,
                             min: nil,
                             max: nil
                           }
                         })
    end

    it 'serializes arrays with of type' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :create do
          input do
            param :tags, type: :array, of: :string, required: false
          end
        end
      end

      definition = contract_class.action_definition(:create).merged_input_definition
      json = definition.as_json

      expect(json).to eq({
                           tags: {
                             nullable: false,
                             of: :string,
                             required: false,
                             type: :array,
                             description: nil,
                             example: nil,
                             format: nil,
                             deprecated: false,
                             min: nil,
                             max: nil
                           }
                         })
    end

    it 'serializes enums' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :create do
          input do
            param :status, type: :string, enum: %w[draft published archived], required: true
          end
        end
      end

      definition = contract_class.action_definition(:create).merged_input_definition
      json = definition.as_json

      expect(json).to eq({
                           status: {
                             enum: %w[draft published archived],
                             nullable: false,
                             required: true,
                             type: :string,
                             description: nil,
                             example: nil,
                             format: nil,
                             deprecated: false,
                             min: nil,
                             max: nil
                           }
                         })
    end

    it 'serializes param with as: transformation' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :create do
          input do
            param :comments, type: :array, as: :comments_attributes, required: false
          end
        end
      end

      definition = contract_class.action_definition(:create).merged_input_definition
      json = definition.as_json

      expect(json).to eq({
                           comments: {
                             as: :comments_attributes,
                             nullable: false,
                             required: false,
                             type: :array,
                             description: nil,
                             example: nil,
                             format: nil,
                             deprecated: false,
                             min: nil,
                             max: nil
                           }
                         })
    end

    it 'serializes union types' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :create do
          input do
            param :value, type: :union, required: true do
              variant type: :string
              variant type: :integer
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).merged_input_definition
      json = definition.as_json

      expect(json).to eq({
                           value: {
                             type: :union,
                             required: true,
                             nullable: false,
                             **default_metadata,
                             variants: [
                               { type: :string },
                               { type: :integer }
                             ]
                           }
                         })
    end

    it 'serializes custom types' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        def self.name; 'TestShippingContract' end

        type :address do
          param :street, type: :string, required: true
          param :city, type: :string, required: true
        end

        action :create do
          input do
            param :shipping_address, type: :address, required: true
          end
        end
      end

      definition = contract_class.action_definition(:create).merged_input_definition
      json = definition.as_json

      # Custom types are serialized as type references (not expanded)
      # This prevents infinite recursion and keeps API introspection clean
      # Note: For non-schema contracts, types are not qualified
      expect(json).to eq({
                           shipping_address: {
                             required: true,
                             nullable: false,
                             type: :address,
                             **default_metadata
                           }
                         })
    end

    it 'returns type references for custom types in unions' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        def self.name; 'TestTest_unionContract' end

        type :test_union_filter_a do
          param :equal, type: :string, required: false
          param :contains, type: :string, required: false
          param :starts_with, type: :string, required: false
        end

        action :search do
          input do
            param :filter, type: :union, required: false do
              variant type: :test_union_filter_a
              variant type: :string
            end
          end
        end
      end

      definition = contract_class.action_definition(:search).merged_input_definition
      json = definition.as_json

      # Now returns type reference instead of expanding inline
      expect(json).to eq({
                           filter: {
                             type: :union,
                             required: false,
                             nullable: false,
                             **default_metadata,
                             variants: [
                               {
                                 type: :test_union_filter_a # Type reference, not expanded
                               },
                               {
                                 type: :string
                               }
                             ]
                           }
                         })
    end

    it 'returns type references for array of custom types in unions' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        def self.name; 'TestTest_array_unionContract' end

        type :test_union_filter_b do
          param :equal, type: :string, required: false
          param :contains, type: :string, required: false
        end

        action :search do
          input do
            param :filters, type: :union, required: false do
              variant type: :test_union_filter_b
              variant type: :array, of: :test_union_filter_b
            end
          end
        end
      end

      definition = contract_class.action_definition(:search).merged_input_definition
      json = definition.as_json

      # Now returns type references instead of expanding inline
      expect(json).to eq({
                           filters: {
                             type: :union,
                             required: false,
                             nullable: false,
                             **default_metadata,
                             variants: [
                               {
                                 type: :test_union_filter_b # Type reference
                               },
                               {
                                 type: :array,
                                 of: :test_union_filter_b # Type reference in 'of' as well
                               }
                             ]
                           }
                         })
    end
  end

  describe 'ActionDefinition#as_json' do
    it 'serializes action with input and output' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :create do
          input do
            param :title, type: :string, required: true
          end

          output do
            param :id, type: :integer, required: true
            param :title, type: :string, required: true
          end
        end
      end

      action_def = contract_class.action_definition(:create)
      json = action_def.as_json

      expect(json).to eq({
                           input: {
                             title: {
                               nullable: false,
                               required: true,
                               type: :string,
                               description: nil,
                               example: nil,
                               format: nil,
                               deprecated: false,
                               min: nil,
                               max: nil
                             }
                           },
                           output: {
                             id: {
                               nullable: false,
                               required: true,
                               type: :integer,
                               description: nil,
                               example: nil,
                               format: nil,
                               deprecated: false,
                               min: nil,
                               max: nil
                             },
                             title: {
                               nullable: false,
                               required: true,
                               type: :string,
                               description: nil,
                               example: nil,
                               format: nil,
                               deprecated: false,
                               min: nil,
                               max: nil
                             }
                           },
                           error_codes: []
                         })
    end

    it 'returns nil for missing definitions' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :destroy do
          # No input or output defined
        end
      end

      action_def = contract_class.action_definition(:destroy)
      json = action_def.as_json

      expect(json).to eq({
                           input: nil,
                           output: nil,
                           error_codes: []
                         })
    end
  end

  describe 'Contract::Base.as_json' do
    it 'serializes entire contract with all actions' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :index do
          output do
            param :posts, type: :array, required: true
          end
        end

        action :create do
          input do
            param :title, type: :string, required: true
          end

          output do
            param :id, type: :integer, required: true
          end
        end
      end

      json = contract_class.as_json

      expect(json[:actions].keys).to contain_exactly(:index, :create)
      expect(json[:actions][:index]).to have_key(:input)
      expect(json[:actions][:index]).to have_key(:output)
      expect(json[:actions][:create]).to have_key(:input)
      expect(json[:actions][:create]).to have_key(:output)
    end
  end

  describe 'Contract::Base.introspect' do
    it 'returns introspection for specific action' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        action :create do
          input do
            param :title, type: :string, required: true
          end
        end

        action :update do
          input do
            param :body, type: :string, required: false
          end
        end
      end

      json = contract_class.introspect(:create)

      expect(json).to eq({
                           input: {
                             title: {
                               nullable: false,
                               required: true,
                               type: :string,
                               description: nil,
                               example: nil,
                               format: nil,
                               deprecated: false,
                               min: nil,
                               max: nil
                             }
                           },
                           output: nil,
                           error_codes: []
                         })
    end

    it 'returns nil for non-existent action' do
      contract_class = Class.new(Apiwork::Contract::Base)

      json = contract_class.introspect(:nonexistent)

      expect(json).to be_nil
    end
  end

  describe 'Contract::Base.as_json with API routing configuration' do
    context 'when API definition is available' do
      before do
        # Ensure API is loaded
        load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)
      end

      it 'includes all CRUD actions plus custom actions when no restrictions specified' do
        # PostContract should include actions based on API routing configuration
        # as defined in /spec/dummy/config/apis/v1.rb: resources :posts with member/collection actions
        json = Api::V1::PostContract.as_json

        # Should have all CRUD actions
        expect(json[:actions].keys).to include(:index, :show, :create, :update, :destroy)

        # Should also have member actions declared in routing
        expect(json[:actions].keys).to include(:publish, :archive, :preview)

        # Should also have collection actions declared in routing
        expect(json[:actions].keys).to include(:search, :bulk_create)
      end

      it 'serializes actions with their input/output definitions' do
        # Verify that actions have their full definitions including schema-generated params
        json = Api::V1::PostContract.as_json

        # :index should have input with filter/sort/page/include params from schema
        expect(json[:actions][:index]).to have_key(:input)
        expect(json[:actions][:index]).to have_key(:output)

        # :show should have input/output
        expect(json[:actions][:show]).to have_key(:input)
        expect(json[:actions][:show]).to have_key(:output)
      end
    end

    context 'when API definition is not available' do
      it 'falls back to explicitly defined actions' do
        # Create a contract without any API definition
        contract_class = Class.new(Apiwork::Contract::Base) do
          action :custom_action do
            input do
              param :name, type: :string
            end
          end
        end

        json = contract_class.as_json

        # Should only have explicitly defined action
        expect(json[:actions].keys).to eq([:custom_action])
      end
    end
  end
end
