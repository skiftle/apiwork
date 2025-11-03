# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Coercer do
  describe '.coerce' do
    context 'integer type' do
      it 'converts valid integer string to Integer' do
        result = described_class.coerce('42', :integer)

        expect(result).to eq(42)
      end

      it 'converts negative integer string' do
        result = described_class.coerce('-42', :integer)

        expect(result).to eq(-42)
      end

      it 'preserves Integer value' do
        result = described_class.coerce(42, :integer)

        expect(result).to eq(42)
      end

      it 'returns nil for invalid integer string' do
        result = described_class.coerce('abc', :integer)

        expect(result).to be_nil
      end

      it 'returns nil for float string' do
        result = described_class.coerce('3.14', :integer)

        expect(result).to be_nil
      end

      it 'returns nil for nil input' do
        result = described_class.coerce(nil, :integer)

        expect(result).to be_nil
      end
    end

    context 'boolean type' do
      it 'converts "true" to true' do
        result = described_class.coerce('true', :boolean)

        expect(result).to be true
      end

      it 'converts "1" to true' do
        result = described_class.coerce('1', :boolean)

        expect(result).to be true
      end

      it 'converts "yes" to true' do
        result = described_class.coerce('yes', :boolean)

        expect(result).to be true
      end

      it 'converts "false" to false' do
        result = described_class.coerce('false', :boolean)

        expect(result).to be false
      end

      it 'converts "0" to false' do
        result = described_class.coerce('0', :boolean)

        expect(result).to be false
      end

      it 'converts "no" to false' do
        result = described_class.coerce('no', :boolean)

        expect(result).to be false
      end

      it 'is case insensitive' do
        expect(described_class.coerce('TRUE', :boolean)).to be true
        expect(described_class.coerce('FALSE', :boolean)).to be false
      end

      it 'returns nil for invalid boolean string' do
        result = described_class.coerce('maybe', :boolean)

        expect(result).to be_nil
      end

      it 'preserves boolean value' do
        expect(described_class.coerce(true, :boolean)).to be true
        expect(described_class.coerce(false, :boolean)).to be false
      end
    end

    context 'datetime type' do
      it 'converts ISO8601 string to Time' do
        result = described_class.coerce('2024-01-01T10:00:00Z', :datetime)

        expect(result).to be_a(Time)
        expect(result.year).to eq(2024)
        expect(result.month).to eq(1)
        expect(result.day).to eq(1)
      end

      it 'preserves Time value' do
        time = Time.zone.now
        result = described_class.coerce(time, :datetime)

        expect(result).to eq(time)
      end

      it 'preserves DateTime value' do
        datetime = DateTime.now
        result = described_class.coerce(datetime, :datetime)

        expect(result).to eq(datetime)
      end

      it 'returns nil for invalid datetime string' do
        result = described_class.coerce('not-a-date', :datetime)

        expect(result).to be_nil
      end

      it 'returns nil for nil input' do
        result = described_class.coerce(nil, :datetime)

        expect(result).to be_nil
      end
    end

    context 'date type' do
      it 'converts date string to Date' do
        result = described_class.coerce('2024-01-01', :date)

        expect(result).to be_a(Date)
        expect(result.year).to eq(2024)
        expect(result.month).to eq(1)
        expect(result.day).to eq(1)
      end

      it 'preserves Date value' do
        date = Date.today
        result = described_class.coerce(date, :date)

        expect(result).to eq(date)
      end

      it 'returns nil for invalid date string' do
        result = described_class.coerce('invalid', :date)

        expect(result).to be_nil
      end
    end

    context 'float type' do
      it 'converts float string to Float' do
        result = described_class.coerce('3.14', :float)

        expect(result).to eq(3.14)
      end

      it 'converts integer string to Float' do
        result = described_class.coerce('42', :float)

        expect(result).to eq(42.0)
      end

      it 'preserves Float value' do
        result = described_class.coerce(3.14, :float)

        expect(result).to eq(3.14)
      end

      it 'returns nil for invalid float string' do
        result = described_class.coerce('abc', :float)

        expect(result).to be_nil
      end
    end

    context 'decimal type' do
      it 'converts decimal string to BigDecimal' do
        result = described_class.coerce('19.99', :decimal)

        expect(result).to be_a(BigDecimal)
        expect(result).to eq(BigDecimal('19.99'))
      end

      it 'preserves BigDecimal value' do
        decimal = BigDecimal('19.99')
        result = described_class.coerce(decimal, :decimal)

        expect(result).to eq(decimal)
      end

      it 'returns nil for invalid decimal string' do
        result = described_class.coerce('abc', :decimal)

        expect(result).to be_nil
      end
    end

    context 'uuid type' do
      it 'preserves valid UUID string' do
        uuid = '550e8400-e29b-41d4-a716-446655440000'
        result = described_class.coerce(uuid, :uuid)

        expect(result).to eq(uuid)
      end

      it 'returns nil for invalid UUID' do
        result = described_class.coerce('not-a-uuid', :uuid)

        expect(result).to be_nil
      end

      it 'returns nil for nil input' do
        result = described_class.coerce(nil, :uuid)

        expect(result).to be_nil
      end
    end

    context 'string type' do
      it 'preserves String value' do
        result = described_class.coerce('hello', :string)

        expect(result).to eq('hello')
      end

      it 'converts other types to string' do
        expect(described_class.coerce(42, :string)).to eq('42')
        expect(described_class.coerce(true, :string)).to eq('true')
      end

      it 'returns nil for nil input' do
        result = described_class.coerce(nil, :string)

        expect(result).to be_nil
      end
    end

    context 'unknown type' do
      it 'returns original value' do
        result = described_class.coerce('value', :unknown_type)

        expect(result).to eq('value')
      end
    end
  end
end
