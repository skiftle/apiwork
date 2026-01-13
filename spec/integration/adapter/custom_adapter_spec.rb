# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Adapter', type: :integration do
  describe 'Adapter::Base subclassing' do
    let(:custom_adapter_class) do
      Class.new(Apiwork::Adapter::Base) do
        adapter_name :billing

        def render_collection(collection, schema_class, state)
          {
            data: collection.map { |record| serialize_record(record, schema_class, state) },
            meta: { adapter: 'billing', total: collection.size },
          }
        end

        def render_record(record, schema_class, state)
          {
            data: serialize_record(record, schema_class, state),
            meta: { adapter: 'billing' },
          }
        end

        def render_error(layer, issues, _state)
          {
            errors: issues.map do |issue|
              {
                code: issue.code,
                message: issue.detail,
                source: { pointer: issue.pointer },
              }
            end,
            meta: { layer:, adapter: 'billing' },
          }
        end

        private

        def serialize_record(record, schema_class, state)
          schema_class.as_json(record, context: state.context, include: state.includes)
        end
      end
    end

    it 'can define adapter_name' do
      expect(custom_adapter_class.adapter_name).to eq(:billing)
    end

    it 'can be instantiated' do
      adapter = custom_adapter_class.new
      expect(adapter).to be_a(Apiwork::Adapter::Base)
    end

    it 'inherits from Adapter::Base' do
      expect(custom_adapter_class.superclass).to eq(Apiwork::Adapter::Base)
    end
  end

  describe 'Adapter registration' do
    it 'registers adapters in the registry' do
      expect(Apiwork::Adapter.registered?(:standard)).to be(true)
    end

    it 'can find registered adapters' do
      standard_adapter_class = Apiwork::Adapter.find!(:standard)
      expect(standard_adapter_class).to be_a(Class)
      expect(standard_adapter_class.ancestors).to include(Apiwork::Adapter::Base)
    end

    it 'can register new adapters' do
      invoice_adapter_class = Class.new(Apiwork::Adapter::Base) do
        adapter_name :invoice_adapter
      end

      Apiwork::Adapter.register(invoice_adapter_class)
      expect(Apiwork::Adapter.registered?(:invoice_adapter)).to be(true)
    end
  end

  describe 'Adapter::Base methods' do
    let(:adapter) { Apiwork::Adapter::Standard.new }

    it 'responds to render_collection' do
      expect(adapter).to respond_to(:render_collection)
    end

    it 'responds to render_record' do
      expect(adapter).to respond_to(:render_record)
    end

    it 'responds to render_error' do
      expect(adapter).to respond_to(:render_error)
    end

    it 'responds to transform_request' do
      expect(adapter).to respond_to(:transform_request)
    end

    it 'responds to transform_response' do
      expect(adapter).to respond_to(:transform_response)
    end

    it 'responds to register_api' do
      expect(adapter).to respond_to(:register_api)
    end

    it 'responds to register_contract' do
      expect(adapter).to respond_to(:register_contract)
    end
  end

  describe 'Adapter capabilities' do
    let(:api_class) { Apiwork::API.find!('/api/v1') }
    let(:capabilities) { api_class.adapter.build_capabilities(api_class.structure) }

    it 'provides capabilities object for conditional registration' do
      expect(capabilities).to respond_to(:filter_types)
      expect(capabilities).to respond_to(:nullable_filter_types)
      expect(capabilities).to respond_to(:sortable?)
      expect(capabilities).to respond_to(:filterable?)
      expect(capabilities).to respond_to(:resources?)
      expect(capabilities).to respond_to(:index_actions?)
    end

    it 'filter_types returns array of types' do
      expect(capabilities.filter_types).to be_an(Array)
    end

    it 'resources? returns true for API with resources' do
      expect(capabilities.resources?).to be(true)
    end

    it 'filterable? responds with boolean' do
      expect(capabilities.filterable?).to be(true).or be(false)
    end

    it 'sortable? responds with boolean' do
      expect(capabilities.sortable?).to be(true).or be(false)
    end
  end

  describe 'Adapter configuration via API DSL' do
    let(:api_class) { Apiwork::API.find!('/api/v1') }

    it 'API has adapter_config available' do
      expect(api_class.adapter_config).to be_a(Hash)
    end

    it 'adapter instance is accessible via api.adapter' do
      expect(api_class.adapter).to be_a(Apiwork::Adapter::Base)
    end
  end
end
