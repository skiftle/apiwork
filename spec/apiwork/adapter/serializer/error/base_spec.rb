# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Serializer::Error::Base do
  describe '.api_builder' do
    it 'returns the API builder' do
      builder_class = Class.new(Apiwork::Adapter::Builder::API::Base)
      serializer_class = Class.new(described_class) do
        api_builder builder_class
      end

      expect(serializer_class.api_builder).to eq(builder_class)
    end

    it 'returns nil when not set' do
      serializer_class = Class.new(described_class)

      expect(serializer_class.api_builder).to be_nil
    end
  end

  describe '.data_type' do
    it 'returns the data type' do
      serializer_class = Class.new(described_class) do
        data_type :error_response
      end

      expect(serializer_class.data_type).to eq(:error_response)
    end

    it 'returns nil when not set' do
      serializer_class = Class.new(described_class)

      expect(serializer_class.data_type).to be_nil
    end
  end

  describe '#serialize' do
    it 'raises NotImplementedError' do
      serializer = described_class.new

      expect { serializer.serialize(Object.new, context: {}) }.to raise_error(NotImplementedError)
    end
  end
end
