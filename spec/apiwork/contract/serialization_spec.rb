# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract Definition' do
  describe 'Definition#meta' do
    let(:contract_class) { create_test_contract }

    it 'creates meta param if not exists' do
      definition = Apiwork::Contract::Param.new(
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
      expect(definition.params[:meta][:shape]).to be_a(Apiwork::Contract::Param)
      expect(definition.params[:meta][:shape].params[:custom]).to be_present
      expect(definition.params[:meta][:shape].params[:custom][:type]).to eq(:string)
    end

    it 'extends existing meta from adapter' do
      definition = Apiwork::Contract::Param.new(
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

      action = contract_class_with_meta.action_for(:test)
      response = action.response
      body_def = response.body_param

      expect(body_def.params[:meta]).to be_present
      meta_shape = body_def.params[:meta][:shape]
      expect(meta_shape.params[:total_count]).to be_present
      expect(meta_shape.params[:processing_time]).to be_present
    end

    it 'does nothing without a block' do
      definition = Apiwork::Contract::Param.new(
        contract_class,
        action_name: :test,
        wrapped: true,
      )

      definition.meta

      expect(definition.params[:meta]).to be_nil
    end
  end
end
