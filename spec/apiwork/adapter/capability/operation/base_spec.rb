# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Capability::Operation::Base do
  describe '.metadata_shape' do
    it 'returns the metadata shape' do
      shape_class = Class.new(Apiwork::Adapter::Capability::Operation::MetadataShape)
      operation_class = Class.new(described_class) do
        metadata_shape shape_class
      end

      expect(operation_class.metadata_shape).to eq(shape_class)
    end

    it 'returns the metadata shape when set with a block' do
      operation_class = Class.new(described_class) do
        metadata_shape do
          string :label
        end
      end

      expect(operation_class.metadata_shape).to be < Apiwork::Adapter::Capability::Operation::MetadataShape
    end

    it 'returns nil when not set' do
      operation_class = Class.new(described_class)

      expect(operation_class.metadata_shape).to be_nil
    end
  end

  describe '.target' do
    it 'returns the target' do
      operation_class = Class.new(described_class) do
        target :collection
      end

      expect(operation_class.target).to eq(:collection)
    end

    it 'returns nil when not set' do
      operation_class = Class.new(described_class)

      expect(operation_class.target).to be_nil
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      data = []
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      options = {}
      request = Apiwork::Request.new(body: {}, query: {})

      operation = described_class.new(data, representation_class, options, request)

      expect(operation.data).to eq(data)
      expect(operation.representation_class).to eq(representation_class)
      expect(operation.options).to eq(options)
      expect(operation.request).to eq(request)
    end
  end

  describe '#apply' do
    it 'raises NotImplementedError' do
      request = Apiwork::Request.new(body: {}, query: {})
      operation = described_class.new([], Object, {}, request)

      expect { operation.apply }.to raise_error(NotImplementedError)
    end
  end

  describe '#result' do
    it 'returns the result' do
      request = Apiwork::Request.new(body: {}, query: {})
      operation = described_class.new([], Object, {}, request)

      result = operation.result(data: [])

      expect(result).to be_a(Apiwork::Adapter::Capability::Result)
    end
  end

  describe '#translate' do
    it 'returns the translation' do
      I18n.backend.store_translations(
        :en,
        {
          apiwork: { adapters: { unit_op: { capabilities: { unit_cap: { label: 'found' } } } } },
        },
      )
      request = Apiwork::Request.new(body: {}, query: {})
      operation = described_class.new(
        [],
        Object,
        {},
        request,
        translation_context: { adapter_name: :unit_op, capability_name: :unit_cap },
      )

      expect(operation.translate(:label)).to eq('found')
    end

    it 'returns the default when not found' do
      request = Apiwork::Request.new(body: {}, query: {})
      operation = described_class.new(
        [],
        Object,
        {},
        request,
        translation_context: { adapter_name: :nonexistent, capability_name: :nonexistent },
      )

      expect(operation.translate(:missing, default: 'fallback')).to eq('fallback')
    end
  end
end
