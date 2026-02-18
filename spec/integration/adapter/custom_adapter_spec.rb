# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom adapter', type: :integration do
  describe 'Adapter::Base subclassing' do
    let(:custom_adapter_class) do
      Class.new(Apiwork::Adapter::Base) do
        adapter_name :billing
      end
    end

    it 'defines adapter_name' do
      expect(custom_adapter_class.adapter_name).to eq(:billing)
    end

    it 'inherits from Adapter::Base' do
      expect(custom_adapter_class.superclass).to eq(Apiwork::Adapter::Base)
    end
  end

  describe 'adapter registration' do
    it 'registers the standard adapter' do
      expect(Apiwork::Adapter.exists?(:standard)).to be(true)
    end

    it 'finds registered adapters' do
      standard_adapter_class = Apiwork::Adapter.find!(:standard)

      expect(standard_adapter_class).to be_a(Class)
      expect(standard_adapter_class.ancestors).to include(Apiwork::Adapter::Base)
    end

    it 'registers new adapters' do
      invoice_adapter_class = Class.new(Apiwork::Adapter::Base) do
        adapter_name :invoice_processing
      end

      Apiwork::Adapter.register(invoice_adapter_class)

      expect(Apiwork::Adapter.exists?(:invoice_processing)).to be(true)
    end
  end

  describe 'API adapter configuration' do
    it 'exposes adapter_config' do
      api_class = Apiwork::API.find!('/api/v1')

      expect(api_class.adapter_config).to be_a(Apiwork::Configuration)
    end

    it 'exposes adapter instance' do
      api_class = Apiwork::API.find!('/api/v1')

      expect(api_class.adapter).to be_a(Apiwork::Adapter::Base)
    end
  end
end
