# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Base do
  describe Apiwork::Representation::Attribute do
    let(:representation_class) do
      Class.new(Apiwork::Representation::Base) do
        abstract!
      end
    end

    describe 'with inline object shape' do
      it 'stores the element as element' do
        definition = described_class.new(:settings, representation_class) do
          object do
            string :theme
          end
        end

        expect(definition.element).to be_a(Apiwork::Representation::Element)
        expect(definition.element.type).to eq(:object)
      end

      it 'infers type as :object when object block provided' do
        definition = described_class.new(:settings, representation_class) do
          object do
            string :theme
          end
        end

        expect(definition.type).to eq(:object)
      end

      it 'infers type as :array when array block provided' do
        definition = described_class.new(:tags, representation_class) do
          array do
            string
          end
        end

        expect(definition.type).to eq(:array)
        expect(definition.of).to eq(:string)
      end
    end

    describe 'with array of primitives' do
      it 'stores the element type via block' do
        definition = described_class.new(:tags, representation_class) do
          array do
            string
          end
        end

        expect(definition.of).to eq(:string)
        expect(definition.type).to eq(:array)
        expect(definition.element).to be_a(Apiwork::Representation::Element)
      end
    end

    describe 'with array of objects' do
      it 'stores type and element' do
        definition = described_class.new(:line_items, representation_class) do
          array do
            object do
              string :name
              decimal :price
            end
          end
        end

        expect(definition.type).to eq(:array)
        expect(definition.element).to be_a(Apiwork::Representation::Element)
        expect(definition.element.of_type).to eq(:object)
      end
    end

    describe 'without inline shape' do
      it 'has nil element' do
        definition = described_class.new(:metadata, representation_class, type: :unknown)

        expect(definition.element).to be_nil
        expect(definition.type).to eq(:unknown)
      end
    end
  end

  describe '.attribute' do
    it 'passes block to Attribute' do
      representation_class = Class.new(described_class) do
        abstract!

        attribute :settings do
          object do
            string :theme
          end
        end
      end

      definition = representation_class.attributes[:settings]

      expect(definition.element).to be_a(Apiwork::Representation::Element)
      expect(definition.type).to eq(:object)
    end

    it 'stores element type for arrays via block' do
      representation_class = Class.new(described_class) do
        abstract!

        attribute :tags do
          array do
            string
          end
        end
      end

      definition = representation_class.attributes[:tags]

      expect(definition.type).to eq(:array)
      expect(definition.of).to eq(:string)
    end
  end

  describe 'preload option' do
    describe 'Attribute#preload' do
      it 'stores simple preload' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :total, preload: :items, type: :decimal
        end

        expect(representation_class.attributes[:total].preload).to eq(:items)
      end

      it 'stores array preload' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :total, preload: [:items, :customer], type: :decimal
        end

        expect(representation_class.attributes[:total].preload).to eq([:items, :customer])
      end

      it 'stores nested preload' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :total, preload: { items: :tax_rates }, type: :decimal
        end

        expect(representation_class.attributes[:total].preload).to eq({ items: :tax_rates })
      end

      it 'defaults to nil' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :name, type: :string
        end

        expect(representation_class.attributes[:name].preload).to be_nil
      end
    end

    describe '.preloads' do
      it 'collects preloads from all attributes' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :name, type: :string
          attribute :total, preload: :items, type: :decimal
          attribute :tax, preload: { items: :tax_rates }, type: :decimal
        end

        expect(representation_class.preloads).to contain_exactly(:items, { items: :tax_rates })
      end

      it 'returns empty array when no preloads' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :name, type: :string
        end

        expect(representation_class.preloads).to eq([])
      end
    end
  end
end
