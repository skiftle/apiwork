# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Generator::Options do
  describe '.build' do
    context 'with no options' do
      it 'returns empty hash' do
        expect(described_class.build).to eq({})
      end
    end

    context 'with key_transform' do
      it 'parses valid key_transform' do
        result = described_class.build(key_transform: 'camel')
        expect(result).to eq({ key_transform: :camel })
      end

      it 'raises error for invalid key_transform' do
        expect do
          described_class.build(key_transform: 'invalid')
        end.to raise_error(ArgumentError, /Invalid key_transform/)
      end
    end

    context 'with version' do
      it 'includes version as string' do
        result = described_class.build(version: '3.1.0')
        expect(result).to eq({ version: '3.1.0' })
      end

      it 'converts version to string' do
        result = described_class.build(version: 3)
        expect(result).to eq({ version: '3' })
      end

      it 'omits version when nil' do
        result = described_class.build(version: nil)
        expect(result).to eq({})
      end
    end

    context 'with both key_transform and version' do
      it 'includes both options' do
        result = described_class.build(key_transform: 'underscore', version: '3.0.0')
        expect(result).to eq({ key_transform: :underscore, version: '3.0.0' })
      end
    end

    context 'with unknown options' do
      it 'ignores unknown options' do
        result = described_class.build(
          key_transform: 'camel',
          version: '3.1.0',
          unknown_option: 'value',
          another_unknown: 123
        )
        expect(result).to eq({ key_transform: :camel, version: '3.1.0' })
      end
    end
  end
end
