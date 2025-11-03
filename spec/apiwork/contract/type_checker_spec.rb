# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::TypeChecker do
  describe '.valid?' do
    let(:field_def) { double('FieldDefinition', type: :string, allows_nil?: true) }

    context 'with nullable field' do
      let(:nullable_field) { double('FieldDefinition', type: :string, allows_nil?: true) }

      it 'allows nil value' do
        result = described_class.valid?(nil, nullable_field)

        expect(result).to be true
      end

      it 'allows empty string (coerced to nil)' do
        result = described_class.valid?('', nullable_field)

        expect(result).to be true
      end
    end

    context 'with non-nullable field' do
      let(:non_nullable_field) { double('FieldDefinition', type: :string, allows_nil?: false) }

      it 'rejects nil value' do
        result = described_class.valid?(nil, non_nullable_field)

        expect(result).to be false
      end

      it 'accepts empty string (empty string is not null)' do
        result = described_class.valid?('', non_nullable_field)

        expect(result).to be true
      end
    end

    context 'string type' do
      let(:string_field) { double('FieldDefinition', type: :string, allows_nil?: false) }

      it 'accepts String value' do
        result = described_class.valid?('hello', string_field)

        expect(result).to be true
      end

      it 'rejects Integer value' do
        result = described_class.valid?(42, string_field)

        expect(result).to be false
      end

      it 'rejects Boolean value' do
        result = described_class.valid?(true, string_field)

        expect(result).to be false
      end
    end

    context 'integer type' do
      let(:integer_field) { double('FieldDefinition', type: :integer, allows_nil?: false) }

      it 'accepts Integer value' do
        result = described_class.valid?(42, integer_field)

        expect(result).to be true
      end

      it 'rejects String value' do
        result = described_class.valid?('42', integer_field)

        expect(result).to be false
      end

      it 'rejects Float value' do
        result = described_class.valid?(42.5, integer_field)

        expect(result).to be false
      end
    end

    context 'boolean type' do
      let(:boolean_field) { double('FieldDefinition', type: :boolean, allows_nil?: false) }

      it 'accepts true' do
        result = described_class.valid?(true, boolean_field)

        expect(result).to be true
      end

      it 'accepts false' do
        result = described_class.valid?(false, boolean_field)

        expect(result).to be true
      end

      it 'rejects string "true"' do
        result = described_class.valid?('true', boolean_field)

        expect(result).to be false
      end

      it 'rejects integer 1' do
        result = described_class.valid?(1, boolean_field)

        expect(result).to be false
      end
    end

    context 'uuid type' do
      let(:uuid_field) { double('FieldDefinition', type: :uuid, allows_nil?: false) }

      it 'accepts valid UUID string' do
        uuid = '550e8400-e29b-41d4-a716-446655440000'
        result = described_class.valid?(uuid, uuid_field)

        expect(result).to be true
      end

      it 'rejects invalid UUID format' do
        result = described_class.valid?('not-a-uuid', uuid_field)

        expect(result).to be false
      end

      it 'rejects integer' do
        result = described_class.valid?(12345, uuid_field)

        expect(result).to be false
      end
    end

    context 'datetime type' do
      let(:datetime_field) { double('FieldDefinition', type: :datetime, allows_nil?: false) }

      it 'accepts Time instance' do
        time = Time.zone.now
        result = described_class.valid?(time, datetime_field)

        expect(result).to be true
      end

      it 'accepts DateTime instance' do
        datetime = DateTime.now
        result = described_class.valid?(datetime, datetime_field)

        expect(result).to be true
      end

      it 'rejects string' do
        result = described_class.valid?('2024-01-01', datetime_field)

        expect(result).to be false
      end
    end

    context 'date type' do
      let(:date_field) { double('FieldDefinition', type: :date, allows_nil?: false) }

      it 'accepts Date instance' do
        date = Date.today
        result = described_class.valid?(date, date_field)

        expect(result).to be true
      end

      it 'rejects string' do
        result = described_class.valid?('2024-01-01', date_field)

        expect(result).to be false
      end
    end

    context 'float type' do
      let(:float_field) { double('FieldDefinition', type: :float, allows_nil?: false) }

      it 'accepts Float value' do
        result = described_class.valid?(3.14, float_field)

        expect(result).to be true
      end

      it 'accepts Integer value (auto-converts to float)' do
        result = described_class.valid?(3, float_field)

        expect(result).to be true
      end

      it 'rejects String value' do
        result = described_class.valid?('3.14', float_field)

        expect(result).to be false
      end
    end

    context 'decimal type' do
      let(:decimal_field) { double('FieldDefinition', type: :decimal, allows_nil?: false) }

      it 'accepts BigDecimal value' do
        decimal = BigDecimal('19.99')
        result = described_class.valid?(decimal, decimal_field)

        expect(result).to be true
      end

      it 'accepts Float value (Numeric)' do
        result = described_class.valid?(19.99, decimal_field)

        expect(result).to be true
      end

      it 'accepts Integer value (Numeric)' do
        result = described_class.valid?(19, decimal_field)

        expect(result).to be true
      end

      it 'rejects String value' do
        result = described_class.valid?('19.99', decimal_field)

        expect(result).to be false
      end
    end

    context 'array type (using Hash spec)' do
      let(:array_field) { double('FieldDefinition', type: { array: :string }, allows_nil?: false) }

      it 'accepts Array value with correct element type' do
        result = described_class.valid?(['a', 'b', 'c'], array_field)

        expect(result).to be true
      end

      it 'rejects non-Array value' do
        result = described_class.valid?('not an array', array_field)

        expect(result).to be false
      end

      it 'rejects Array with wrong element type' do
        result = described_class.valid?([1, 2, 3], array_field)

        expect(result).to be false
      end
    end

    context 'json type' do
      let(:json_field) { double('FieldDefinition', type: :json, allows_nil?: false) }

      it 'accepts Hash value' do
        result = described_class.valid?({ key: 'value' }, json_field)

        expect(result).to be true
      end

      it 'accepts Array value' do
        result = described_class.valid?([1, 2, 3], json_field)

        expect(result).to be true
      end

      it 'rejects String value' do
        result = described_class.valid?('not json', json_field)

        expect(result).to be false
      end
    end
  end
end
