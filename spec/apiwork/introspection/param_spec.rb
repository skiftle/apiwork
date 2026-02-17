# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param do
  describe '.build' do
    context 'when type is :string' do
      it 'returns a String param' do
        result = described_class.build(type: :string)

        expect(result).to be_a(Apiwork::Introspection::Param::String)
      end
    end

    context 'when type is :integer' do
      it 'returns an Integer param' do
        result = described_class.build(type: :integer)

        expect(result).to be_a(Apiwork::Introspection::Param::Integer)
      end
    end

    context 'when type is :number' do
      it 'returns a Number param' do
        result = described_class.build(type: :number)

        expect(result).to be_a(Apiwork::Introspection::Param::Number)
      end
    end

    context 'when type is :decimal' do
      it 'returns a Decimal param' do
        result = described_class.build(type: :decimal)

        expect(result).to be_a(Apiwork::Introspection::Param::Decimal)
      end
    end

    context 'when type is :boolean' do
      it 'returns a Boolean param' do
        result = described_class.build(type: :boolean)

        expect(result).to be_a(Apiwork::Introspection::Param::Boolean)
      end
    end

    context 'when type is :datetime' do
      it 'returns a DateTime param' do
        result = described_class.build(type: :datetime)

        expect(result).to be_a(Apiwork::Introspection::Param::DateTime)
      end
    end

    context 'when type is :date' do
      it 'returns a Date param' do
        result = described_class.build(type: :date)

        expect(result).to be_a(Apiwork::Introspection::Param::Date)
      end
    end

    context 'when type is :time' do
      it 'returns a Time param' do
        result = described_class.build(type: :time)

        expect(result).to be_a(Apiwork::Introspection::Param::Time)
      end
    end

    context 'when type is :uuid' do
      it 'returns a UUID param' do
        result = described_class.build(type: :uuid)

        expect(result).to be_a(Apiwork::Introspection::Param::UUID)
      end
    end

    context 'when type is :binary' do
      it 'returns a Binary param' do
        result = described_class.build(type: :binary)

        expect(result).to be_a(Apiwork::Introspection::Param::Binary)
      end
    end

    context 'when type is :unknown' do
      it 'returns an Unknown param' do
        result = described_class.build(type: :unknown)

        expect(result).to be_a(Apiwork::Introspection::Param::Unknown)
      end
    end

    context 'when type is :array' do
      it 'returns an Array param' do
        result = described_class.build(type: :array)

        expect(result).to be_a(Apiwork::Introspection::Param::Array)
      end
    end

    context 'when type is :object' do
      it 'returns an Object param' do
        result = described_class.build(type: :object)

        expect(result).to be_a(Apiwork::Introspection::Param::Object)
      end
    end

    context 'when type is :union' do
      it 'returns a Union param' do
        result = described_class.build(type: :union)

        expect(result).to be_a(Apiwork::Introspection::Param::Union)
      end
    end

    context 'when type is :literal' do
      it 'returns a Literal param' do
        result = described_class.build(type: :literal)

        expect(result).to be_a(Apiwork::Introspection::Param::Literal)
      end
    end

    context 'when type is :reference' do
      it 'returns a Reference param' do
        result = described_class.build(type: :reference)

        expect(result).to be_a(Apiwork::Introspection::Param::Reference)
      end
    end

    context 'with unrecognized type' do
      it 'returns an Unknown param' do
        result = described_class.build(type: :nonexistent)

        expect(result).to be_a(Apiwork::Introspection::Param::Unknown)
      end
    end
  end
end
