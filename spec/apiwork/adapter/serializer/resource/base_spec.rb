# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Serializer::Resource::Base do
  describe '.contract_builder' do
    it 'returns the contract builder' do
      builder_class = Class.new(Apiwork::Adapter::Builder::Contract::Base)
      serializer_class = Class.new(described_class) do
        contract_builder builder_class
      end

      expect(serializer_class.contract_builder).to eq(builder_class)
    end

    it 'returns nil when not set' do
      serializer_class = Class.new(described_class)

      expect(serializer_class.contract_builder).to be_nil
    end
  end

  describe '.data_type' do
    it 'returns the data type' do
      serializer_class = Class.new(described_class) do
        data_type(&:name)
      end

      expect(serializer_class.data_type).to be_a(Proc)
    end

    it 'returns nil when not set' do
      serializer_class = Class.new(described_class)

      expect(serializer_class.data_type).to be_nil
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }

      serializer = described_class.new(representation_class)

      expect(serializer.representation_class).to eq(representation_class)
    end
  end

  describe '#serialize' do
    it 'raises NotImplementedError' do
      serializer = described_class.new(Object)

      expect { serializer.serialize(Object.new, context: {}, serialize_options: {}) }.to raise_error(NotImplementedError)
    end
  end
end
