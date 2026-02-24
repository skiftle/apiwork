# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Builder::Contract::Base do
  describe '#initialize' do
    it 'creates with required attributes' do
      contract_class = create_test_contract
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      builder = described_class.new(contract_class, representation_class)

      expect(builder.representation_class).to eq(representation_class)
    end
  end

  describe '#build' do
    it 'raises NotImplementedError' do
      contract_class = create_test_contract
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      builder = described_class.new(contract_class, representation_class)

      expect { builder.build }.to raise_error(NotImplementedError)
    end
  end
end
