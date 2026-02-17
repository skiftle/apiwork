# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Inheritance do
  describe '#initialize' do
    it 'creates with required attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      inheritance = described_class.new(representation_class)

      expect(inheritance.base_class).to eq(representation_class)
      expect(inheritance.subclasses).to eq([])
    end
  end

  describe '#column' do
    it 'returns the inheritance column' do
      base = Class.new(Apiwork::Representation::Base) do
        abstract!
        model Client
      end
      inheritance = described_class.new(base)

      expect(inheritance.column).to eq(:type)
    end
  end

  describe '#mapping' do
    it 'returns the mapping' do
      base = Class.new(Apiwork::Representation::Base) do
        abstract!
        model Client
      end
      sub = Class.new(base) do
        model PersonClient
        type_name :person
      end
      inheritance = described_class.new(base)
      inheritance.register(sub)

      expect(inheritance.mapping).to eq({ 'person' => 'PersonClient' })
    end
  end

  describe '#resolve' do
    context 'when subclass matches' do
      it 'returns the subclass representation' do
        base = Class.new(Apiwork::Representation::Base) do
          abstract!
          model Client
        end
        sub = Class.new(base) do
          model PersonClient
        end
        inheritance = described_class.new(base)
        inheritance.register(sub)
        record = PersonClient.new

        expect(inheritance.resolve(record)).to eq(sub)
      end
    end

    context 'when no subclass matches' do
      it 'returns nil' do
        base = Class.new(Apiwork::Representation::Base) do
          abstract!
          model Client
        end
        inheritance = described_class.new(base)
        record = PersonClient.new

        expect(inheritance.resolve(record)).to be_nil
      end
    end
  end

  describe '#transform?' do
    context 'when subclass has different STI name' do
      it 'returns true' do
        base = Class.new(Apiwork::Representation::Base) do
          abstract!
          model Client
        end
        sub = Class.new(base) do
          model PersonClient
          type_name :person
        end
        inheritance = described_class.new(base)
        inheritance.register(sub)

        expect(inheritance.transform?).to be(true)
      end
    end

    context 'when subclass has same STI name' do
      it 'returns false' do
        base = Class.new(Apiwork::Representation::Base) do
          abstract!
          model Client
        end
        sub = Class.new(base) do
          model PersonClient
        end
        inheritance = described_class.new(base)
        inheritance.register(sub)

        expect(inheritance.transform?).to be(false)
      end
    end
  end
end
