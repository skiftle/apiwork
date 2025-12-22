# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Inline type definitions in schema attributes' do
  describe Apiwork::Schema::AttributeDefinition do
    let(:schema_class) do
      Class.new(Apiwork::Schema::Base) do
        abstract!
      end
    end

    describe 'with inline object shape' do
      it 'stores the block as inline_shape' do
        block = proc { param :theme, type: :string }
        definition = described_class.new(:settings, schema_class, &block)

        expect(definition.inline_shape).to eq(block)
      end

      it 'infers type as :object when block provided without explicit type' do
        definition = described_class.new(:settings, schema_class) do
          param :theme, type: :string
        end

        expect(definition.type).to eq(:object)
      end

      it 'uses explicit type when provided with block' do
        definition = described_class.new(:settings, schema_class, type: :array) do
          param :name, type: :string
        end

        expect(definition.type).to eq(:array)
      end
    end

    describe 'with array of primitives' do
      it 'stores the of option' do
        definition = described_class.new(:tags, schema_class, type: :array, of: :string)

        expect(definition.of).to eq(:string)
        expect(definition.type).to eq(:array)
        expect(definition.inline_shape).to be_nil
      end
    end

    describe 'with array of objects' do
      it 'stores both type and inline_shape' do
        definition = described_class.new(:line_items, schema_class, type: :array) do
          param :name, type: :string
          param :price, type: :decimal
        end

        expect(definition.type).to eq(:array)
        expect(definition.inline_shape).to be_a(Proc)
      end
    end

    describe 'without inline shape' do
      it 'has nil inline_shape' do
        definition = described_class.new(:metadata, schema_class, type: :json)

        expect(definition.inline_shape).to be_nil
        expect(definition.type).to eq(:json)
      end
    end
  end

  describe 'Schema::Base.attribute' do
    it 'passes block to AttributeDefinition' do
      schema_class = Class.new(Apiwork::Schema::Base) do
        abstract!

        attribute :settings do
          param :theme, type: :string
        end
      end

      definition = schema_class.attribute_definitions[:settings]

      expect(definition.inline_shape).to be_a(Proc)
      expect(definition.type).to eq(:object)
    end

    it 'passes of option for arrays' do
      schema_class = Class.new(Apiwork::Schema::Base) do
        abstract!

        attribute :tags, type: :array, of: :string
      end

      definition = schema_class.attribute_definitions[:tags]

      expect(definition.type).to eq(:array)
      expect(definition.of).to eq(:string)
    end
  end
end
