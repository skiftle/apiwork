# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Capability::Base do
  describe '.api_builder' do
    it 'registers the API builder' do
      builder_class = Class.new(Apiwork::Adapter::Builder::API::Base)
      capability_class = Class.new(described_class) do
        api_builder builder_class
      end

      expect(capability_class._api_builder).to eq(builder_class)
    end

    context 'with block' do
      it 'stores the block' do
        capability_class = Class.new(described_class) do
          api_builder do
            enum(:status, values: %w[active inactive])
          end
        end

        expect(capability_class._api_builder_block).to be_a(Proc)
      end
    end
  end

  describe '.capability_name' do
    it 'returns the capability name' do
      capability_class = Class.new(described_class) do
        capability_name :filtering
      end

      expect(capability_class.capability_name).to eq(:filtering)
    end

    it 'returns nil when not set' do
      capability_class = Class.new(described_class)

      expect(capability_class.capability_name).to be_nil
    end
  end

  describe '.contract_builder' do
    it 'registers the contract builder' do
      builder_class = Class.new(Apiwork::Adapter::Builder::Contract::Base)
      capability_class = Class.new(described_class) do
        contract_builder builder_class
      end

      expect(capability_class._contract_builder).to eq(builder_class)
    end

    context 'with block' do
      it 'stores the block' do
        capability_class = Class.new(described_class) do
          contract_builder do
            object(:invoice) { string :id }
          end
        end

        expect(capability_class._contract_builder_block).to be_a(Proc)
      end
    end
  end

  describe '.operation' do
    it 'registers the operation' do
      operation_class = Class.new(Apiwork::Adapter::Capability::Operation::Base)
      capability_class = Class.new(described_class) do
        operation operation_class
      end

      expect(capability_class._operation_class).to eq(operation_class)
    end

    context 'with block' do
      it 'stores the block' do
        capability_class = Class.new(described_class) do
          operation do
            # operation logic
          end
        end

        expect(capability_class._operation_block).to be_a(Proc)
      end
    end
  end

  describe '.request_transformer' do
    it 'registers the request transformer' do
      transformer_class = Class.new(Apiwork::Adapter::Capability::Transformer::Request::Base)
      capability_class = Class.new(described_class) do
        request_transformer transformer_class
      end

      expect(capability_class.request_transformers).to include(transformer_class)
    end
  end

  describe '.response_transformer' do
    it 'registers the response transformer' do
      transformer_class = Class.new(Apiwork::Adapter::Capability::Transformer::Response::Base)
      capability_class = Class.new(described_class) do
        response_transformer transformer_class
      end

      expect(capability_class.response_transformers).to include(transformer_class)
    end
  end
end
