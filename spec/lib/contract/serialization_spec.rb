# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract Serialization' do
  describe 'ParamDefinition serialization' do
    it 'serializes simple params' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              param :title, type: :string
              param :published, default: false, optional: true, type: :boolean
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          title: { type: :string },
          published: {
            default: false,
            optional: true,
            type: :boolean,
          },
        },
      )
    end

    it 'serializes object with shape' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              param :post, type: :object do
                param :title, type: :string
                param :body, optional: true, type: :string
              end
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          post: {
            type: :object,
            shape: {
              title: { type: :string },
              body: { optional: true, type: :string },
            },
          },
        },
      )
    end

    it 'serializes arrays with of type' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              param :tags, of: :string, optional: true, type: :array
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          tags: {
            of: :string,
            optional: true,
            type: :array,
          },
        },
      )
    end

    it 'serializes enums' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              param :status, enum: %w[draft published archived], type: :string
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          status: { enum: %w[draft published archived], type: :string },
        },
      )
    end

    it 'serializes param with as: transformation' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              param :comments, as: :comments_attributes, optional: true, type: :array
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          comments: {
            as: :comments_attributes,
            optional: true,
            type: :array,
          },
        },
      )
    end

    it 'serializes union types' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              param :value, type: :union do
                variant type: :string
                variant type: :integer
              end
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          value: {
            type: :union,
            variants: [
              { type: :string },
              { type: :integer },
            ],
          },
        },
      )
    end

    it 'serializes custom types' do
      contract_class = create_test_contract do
        type :address do
          param :street, type: :string
          param :city, type: :string
        end

        action :create do
          request do
            body do
              param :shipping_address, type: :address
            end
          end
        end
      end

      definition = contract_class.action_definition(:create).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          shipping_address: { type: :address },
        },
      )
    end

    it 'returns type references for custom types in unions' do
      contract_class = create_test_contract do
        type :test_union_filter_a do
          param :equal, optional: true, type: :string
          param :contains, optional: true, type: :string
          param :starts_with, optional: true, type: :string
        end

        action :search do
          request do
            body do
              param :filter, optional: true, type: :union do
                variant type: :test_union_filter_a
                variant type: :string
              end
            end
          end
        end
      end

      definition = contract_class.action_definition(:search).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          filter: {
            type: :union,
            optional: true,
            variants: [
              { type: :test_union_filter_a },
              { type: :string },
            ],
          },
        },
      )
    end

    it 'returns type references for array of custom types in unions' do
      contract_class = create_test_contract do
        type :test_union_filter_b do
          param :equal, optional: true, type: :string
          param :contains, optional: true, type: :string
        end

        action :search do
          request do
            body do
              param :filters, optional: true, type: :union do
                variant type: :test_union_filter_b
                variant of: :test_union_filter_b, type: :array
              end
            end
          end
        end
      end

      definition = contract_class.action_definition(:search).request_definition.body_param_definition
      json = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize

      expect(json).to eq(
        {
          filters: {
            type: :union,
            optional: true,
            variants: [
              { type: :test_union_filter_b },
              { of: :test_union_filter_b, type: :array },
            ],
          },
        },
      )
    end
  end

  describe 'ActionDefinition serialization' do
    it 'serializes action with input and output' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              param :title, type: :string
            end
          end

          response do
            body do
              param :id, type: :integer
              param :title, type: :string
            end
          end
        end
      end

      action_def = contract_class.action_definition(:create)
      json = Apiwork::Introspection::ActionDefinitionSerializer.new(action_def).serialize

      expect(json).to eq(
        {
          request: {
            body: {
              title: { type: :string },
            },
          },
          response: {
            body: {
              type: :object,
              shape: {
                id: { type: :integer },
                title: { type: :string },
              },
            },
          },
        },
      )
    end

    it 'returns empty hash for missing definitions' do
      contract_class = create_test_contract do
        action :destroy do
          # No input or output defined
        end
      end

      action_def = contract_class.action_definition(:destroy)
      json = Apiwork::Introspection::ActionDefinitionSerializer.new(action_def).serialize

      expect(json).to eq({})
    end
  end

  describe 'Contract::Base.introspect' do
    it 'serializes entire contract with all actions' do
      contract_class = create_test_contract do
        action :index do
          response do
            body do
              param :posts, type: :array
            end
          end
        end

        action :create do
          request do
            body do
              param :title, type: :string
            end
          end

          response do
            body do
              param :id, type: :integer
            end
          end
        end
      end

      json = contract_class.introspect

      expect(json[:actions].keys).to contain_exactly(:index, :create)
      expect(json[:actions][:index]).not_to have_key(:request)
      expect(json[:actions][:index]).to have_key(:response)
      expect(json[:actions][:create]).to have_key(:request)
      expect(json[:actions][:create]).to have_key(:response)
    end

    it 'includes types defined in the contract' do
      contract_class = create_test_contract do
        type :shipping_location do
          param :street, type: :string
          param :city, type: :string
        end

        action :create do
          request do
            body do
              param :shipping, type: :shipping_location
            end
          end
        end
      end

      json = contract_class.introspect

      expect(json).to have_key(:types)
      expect(json[:types].keys).to include(:shipping_location)
      expect(json[:types][:shipping_location][:type]).to eq(:object)
      expect(json[:types][:shipping_location][:shape]).to eq(
        {
          street: { type: :string },
          city: { type: :string },
        },
      )
    end

    it 'includes enums defined in the contract' do
      contract_class = create_test_contract do
        enum :invoice_status, values: %w[draft published archived]

        action :update do
          request do
            body do
              param :status, enum: :invoice_status
            end
          end
        end
      end

      json = contract_class.introspect

      expect(json).to have_key(:enums)
      expect(json[:enums].keys).to include(:invoice_status)
      expect(json[:enums][:invoice_status][:values]).to eq(%w[draft published archived])
    end

    it 'does not include empty types/enums keys' do
      contract_class = create_test_contract do
        action :index do
          response do
            body do
              param :items, type: :array
            end
          end
        end
      end

      json = contract_class.introspect

      expect(json).not_to have_key(:types)
      expect(json).not_to have_key(:enums)
    end

    context 'with expand: true' do
      it 'includes referenced types recursively' do
        api = TestApiHelper.api_class
        api.type :expand_pagination_meta do
          param :page, type: :integer
          param :total, type: :integer
        end

        contract_class = create_test_contract do
          type :expand_item do
            param :name, type: :string
          end

          action :index do
            response do
              body do
                param :items, of: :expand_item, type: :array
                param :meta, type: :expand_pagination_meta
              end
            end
          end
        end

        json = contract_class.introspect(expand: true)

        expect(json[:types].keys).to include(:expand_item)
        expect(json[:types].keys).to include(:expand_pagination_meta)
      end

      it 'does not include unreferenced types' do
        api = TestApiHelper.api_class
        api.type :expand_unreferenced_type do
          param :value, type: :string
        end

        contract_class = create_test_contract do
          type :expand_local_type do
            param :id, type: :integer
          end

          action :show do
            response do
              body do
                param :result, type: :string
              end
            end
          end
        end

        json = contract_class.introspect(expand: true)

        expect(json).not_to have_key(:types)
      end

      it 'includes nested type references' do
        api = TestApiHelper.api_class
        api.type :expand_nested_address do
          param :street, type: :string
          param :city, type: :string
        end

        api.type :expand_nested_person do
          param :name, type: :string
          param :address, type: :expand_nested_address
        end

        contract_class = create_test_contract do
          action :create do
            request do
              body do
                param :person, type: :expand_nested_person
              end
            end
          end
        end

        json = contract_class.introspect(expand: true)

        expect(json[:types].keys).to include(:expand_nested_person)
        expect(json[:types].keys).to include(:expand_nested_address)
      end
    end
  end

  describe 'Contract::Base.introspect with API routing configuration' do
    context 'when API definition is available' do
      before do
        # Ensure API is loaded
        load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)
      end

      it 'includes all CRUD actions plus custom actions when no restrictions specified' do
        # PostContract should include actions based on API routing configuration
        # as defined in /spec/dummy/config/apis/v1.rb: resources :posts with member/collection actions
        json = Api::V1::PostContract.introspect

        # Should have all CRUD actions
        expect(json[:actions].keys).to include(:index, :show, :create, :update, :destroy)

        # Should also have member actions declared in routing
        expect(json[:actions].keys).to include(:publish, :archive, :preview)

        # Should also have collection actions declared in routing
        expect(json[:actions].keys).to include(:search, :bulk_create)
      end

      it 'serializes actions with their input/output definitions' do
        # Verify that actions have their full definitions including schema-generated params
        json = Api::V1::PostContract.introspect

        # :index should have request with filter/sort/page/include params from schema
        expect(json[:actions][:index]).to have_key(:request)
        expect(json[:actions][:index]).to have_key(:response)

        # :show may have response depending on whether schema generates output
        expect(json[:actions]).to have_key(:show)
      end
    end

    context 'when API definition is not available' do
      it 'falls back to explicitly defined actions' do
        contract_class = create_test_contract do
          action :custom_action do
            request do
              body do
                param :name, type: :string
              end
            end
          end
        end

        json = contract_class.introspect

        # Should only have explicitly defined action
        expect(json[:actions].keys).to eq([:custom_action])
      end
    end
  end

  describe 'Definition#meta' do
    let(:contract_class) { create_test_contract }

    it 'creates meta param if not exists' do
      definition = Apiwork::Contract::ParamDefinition.new(
        contract_class,
        action_name: :test,
        wrapped: true,
      )

      definition.meta do
        param :custom, type: :string
      end

      expect(definition.params[:meta]).to be_present
      expect(definition.params[:meta][:type]).to eq(:object)
      expect(definition.params[:meta][:optional]).to be(false)
      expect(definition.params[:meta][:shape]).to be_a(Apiwork::Contract::ParamDefinition)
      expect(definition.params[:meta][:shape].params[:custom]).to be_present
      expect(definition.params[:meta][:shape].params[:custom][:type]).to eq(:string)
    end

    it 'extends existing meta from adapter' do
      definition = Apiwork::Contract::ParamDefinition.new(
        contract_class,
        action_name: :test,
        wrapped: true,
      )

      # Simulate adapter defining meta with pagination
      definition.param :meta, type: :object do
        param :pagination, type: :pagination
      end

      # User extends with custom fields
      definition.meta do
        param :total, type: :integer
        param :custom_field, type: :string
      end

      meta_shape = definition.params[:meta][:shape]
      expect(meta_shape.params[:pagination]).to be_present
      expect(meta_shape.params[:total]).to be_present
      expect(meta_shape.params[:custom_field]).to be_present
    end

    it 'works in response body context' do
      contract_class_with_meta = create_test_contract do
        action :test do
          response do
            body do
              meta do
                param :total_count, type: :integer
                param :processing_time, type: :integer
              end
            end
          end
        end
      end

      action_def = contract_class_with_meta.action_definition(:test)
      response_def = action_def.response_definition
      body_def = response_def.body_param_definition

      expect(body_def.params[:meta]).to be_present
      meta_shape = body_def.params[:meta][:shape]
      expect(meta_shape.params[:total_count]).to be_present
      expect(meta_shape.params[:processing_time]).to be_present
    end

    it 'does nothing without a block' do
      definition = Apiwork::Contract::ParamDefinition.new(
        contract_class,
        action_name: :test,
        wrapped: true,
      )

      definition.meta

      expect(definition.params[:meta]).to be_nil
    end
  end
end
