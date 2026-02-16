# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::RootKey do
  describe '#initialize' do
    context 'with defaults' do
      it 'creates with required attributes' do
        root_key = described_class.new('invoice')

        expect(root_key.singular).to eq('invoice')
        expect(root_key.plural).to eq('invoices')
      end
    end

    context 'with overrides' do
      it 'accepts singular and plural' do
        root_key = described_class.new('bill', 'bills')

        expect(root_key.singular).to eq('bill')
        expect(root_key.plural).to eq('bills')
      end
    end
  end
end
