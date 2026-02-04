# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Object::Coercer do
  let(:contract_class) { create_test_contract }

  def build_shape(type:)
    shape = Apiwork::Contract::Object.new(contract_class)
    shape.param(:value, type:)
    shape
  end

  def coerce(value, type:)
    shape = build_shape(type:)
    result = described_class.coerce(shape, { value: })
    result[:value]
  end

  describe '.coerce' do
    context 'integer type' do
      it 'converts valid integer string to Integer' do
        expect(coerce('42', type: :integer)).to eq(42)
      end

      it 'converts negative integer string' do
        expect(coerce('-42', type: :integer)).to eq(-42)
      end

      it 'preserves Integer value' do
        expect(coerce(42, type: :integer)).to eq(42)
      end

      it 'returns original value for invalid integer string' do
        expect(coerce('abc', type: :integer)).to eq('abc')
      end

      it 'returns original value for float string' do
        expect(coerce('3.14', type: :integer)).to eq('3.14')
      end

      it 'preserves nil input' do
        expect(coerce(nil, type: :integer)).to be_nil
      end
    end

    context 'boolean type' do
      it 'converts "true" to true' do
        expect(coerce('true', type: :boolean)).to be true
      end

      it 'converts "1" to true' do
        expect(coerce('1', type: :boolean)).to be true
      end

      it 'converts "yes" to true' do
        expect(coerce('yes', type: :boolean)).to be true
      end

      it 'converts "false" to false' do
        expect(coerce('false', type: :boolean)).to be false
      end

      it 'converts "0" to false' do
        expect(coerce('0', type: :boolean)).to be false
      end

      it 'converts "no" to false' do
        expect(coerce('no', type: :boolean)).to be false
      end

      it 'is case insensitive' do
        expect(coerce('TRUE', type: :boolean)).to be true
        expect(coerce('FALSE', type: :boolean)).to be false
      end

      it 'returns original value for invalid boolean string' do
        expect(coerce('maybe', type: :boolean)).to eq('maybe')
      end

      it 'preserves boolean value' do
        expect(coerce(true, type: :boolean)).to be true
        expect(coerce(false, type: :boolean)).to be false
      end
    end

    context 'datetime type' do
      it 'converts ISO8601 string to Time' do
        result = coerce('2024-01-01T10:00:00Z', type: :datetime)

        expect(result).to be_a(Time)
        expect(result.year).to eq(2024)
        expect(result.month).to eq(1)
        expect(result.day).to eq(1)
      end

      it 'preserves Time value' do
        time = Time.zone.now
        expect(coerce(time, type: :datetime)).to eq(time)
      end

      it 'preserves DateTime value' do
        datetime = DateTime.now
        expect(coerce(datetime, type: :datetime)).to eq(datetime)
      end

      it 'returns original value for invalid datetime string' do
        expect(coerce('not-a-date', type: :datetime)).to eq('not-a-date')
      end

      it 'preserves nil input' do
        expect(coerce(nil, type: :datetime)).to be_nil
      end
    end

    context 'date type' do
      it 'converts date string to Date' do
        result = coerce('2024-01-01', type: :date)

        expect(result).to be_a(Date)
        expect(result.year).to eq(2024)
        expect(result.month).to eq(1)
        expect(result.day).to eq(1)
      end

      it 'preserves Date value' do
        date = Time.zone.today
        expect(coerce(date, type: :date)).to eq(date)
      end

      it 'returns original value for invalid date string' do
        expect(coerce('invalid', type: :date)).to eq('invalid')
      end
    end

    context 'time type' do
      it 'converts time string to Time' do
        result = coerce('10:30:00', type: :time)

        expect(result).to be_a(Time)
        expect(result.hour).to eq(10)
        expect(result.min).to eq(30)
        expect(result.sec).to eq(0)
      end

      it 'converts time string without seconds' do
        result = coerce('14:45', type: :time)

        expect(result).to be_a(Time)
        expect(result.hour).to eq(14)
        expect(result.min).to eq(45)
      end

      it 'preserves Time value' do
        time = Time.zone.now
        expect(coerce(time, type: :time)).to eq(time)
      end

      it 'returns original value for invalid time string' do
        expect(coerce('invalid', type: :time)).to eq('invalid')
      end

      it 'preserves nil input' do
        expect(coerce(nil, type: :time)).to be_nil
      end
    end

    context 'number type' do
      it 'converts number string to Float' do
        expect(coerce('3.14', type: :number)).to eq(3.14)
      end

      it 'converts integer string to Float' do
        expect(coerce('42', type: :number)).to eq(42.0)
      end

      it 'preserves Float value' do
        expect(coerce(3.14, type: :number)).to eq(3.14)
      end

      it 'returns original value for invalid number string' do
        expect(coerce('abc', type: :number)).to eq('abc')
      end
    end

    context 'decimal type' do
      it 'converts decimal string to BigDecimal' do
        result = coerce('19.99', type: :decimal)

        expect(result).to be_a(BigDecimal)
        expect(result).to eq(BigDecimal('19.99'))
      end

      it 'preserves BigDecimal value' do
        decimal = BigDecimal('19.99')
        expect(coerce(decimal, type: :decimal)).to eq(decimal)
      end

      it 'returns original value for invalid decimal string' do
        expect(coerce('abc', type: :decimal)).to eq('abc')
      end
    end

    context 'uuid type' do
      it 'preserves valid UUID string' do
        uuid = '550e8400-e29b-41d4-a716-446655440000'
        expect(coerce(uuid, type: :uuid)).to eq(uuid)
      end

      it 'returns original value for invalid UUID' do
        expect(coerce('not-a-uuid', type: :uuid)).to eq('not-a-uuid')
      end

      it 'preserves nil input' do
        expect(coerce(nil, type: :uuid)).to be_nil
      end
    end

    context 'string type' do
      it 'preserves String value' do
        expect(coerce('hello', type: :string)).to eq('hello')
      end

      it 'converts other types to string' do
        expect(coerce(42, type: :string)).to eq('42')
        expect(coerce(true, type: :string)).to eq('true')
      end

      it 'preserves nil input' do
        expect(coerce(nil, type: :string)).to be_nil
      end
    end

    context 'unknown type' do
      it 'returns original value' do
        expect(coerce('value', type: :unknown_type)).to eq('value')
      end
    end
  end
end
