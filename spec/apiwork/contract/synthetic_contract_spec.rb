# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Synthetic contracts' do
  let(:representation_without_contract) do
    Class.new(Apiwork::Representation::Base) do
      def self.name
        'OrphanRepresentation'
      end

      abstract!

      attribute :id
      attribute :name
    end
  end

  let(:representation_with_contract) do
    Class.new(Apiwork::Representation::Base) do
      def self.name
        'WithContractRepresentation'
      end

      abstract!

      attribute :id
    end
  end

  let(:explicit_contract) do
    rep = representation_with_contract
    Class.new(Apiwork::Contract::Base) do
      def self.name
        'WithContractContract'
      end

      representation rep
    end
  end

  before do
    stub_const('OrphanRepresentation', representation_without_contract)
    stub_const('WithContractRepresentation', representation_with_contract)
    stub_const('WithContractContract', explicit_contract)
  end

  after do
    Apiwork::Contract::Base._synthetic_contracts.clear
  end

  describe '.find_contract_for_representation' do
    context 'when explicit contract exists' do
      it 'returns the explicit contract' do
        contract = Apiwork::Contract::Base.find_contract_for_representation(WithContractRepresentation)
        expect(contract).to eq(WithContractContract)
      end

      it 'does not create synthetic contract' do
        Apiwork::Contract::Base.find_contract_for_representation(WithContractRepresentation)
        expect(Apiwork::Contract::Base._synthetic_contracts).to be_empty
      end
    end

    context 'when no explicit contract exists' do
      it 'creates a synthetic contract' do
        contract = Apiwork::Contract::Base.find_contract_for_representation(OrphanRepresentation)
        expect(contract).to be_present
        expect(contract).to be < Apiwork::Contract::Base
      end

      it 'caches the synthetic contract' do
        first_call = Apiwork::Contract::Base.find_contract_for_representation(OrphanRepresentation)
        second_call = Apiwork::Contract::Base.find_contract_for_representation(OrphanRepresentation)
        expect(first_call).to equal(second_call)
      end

      it 'sets representation_class on synthetic contract' do
        contract = Apiwork::Contract::Base.find_contract_for_representation(OrphanRepresentation)
        expect(contract.representation_class).to eq(OrphanRepresentation)
      end

      it 'synthetic contract is anonymous (no name)' do
        contract = Apiwork::Contract::Base.find_contract_for_representation(OrphanRepresentation)
        expect(contract.name).to be_nil
      end
    end

    context 'when representation has no name' do
      it 'returns nil' do
        anonymous_representation = Class.new(Apiwork::Representation::Base)
        contract = Apiwork::Contract::Base.find_contract_for_representation(anonymous_representation)
        expect(contract).to be_nil
      end
    end

    context 'when representation is nil' do
      it 'returns nil' do
        contract = Apiwork::Contract::Base.find_contract_for_representation(nil)
        expect(contract).to be_nil
      end
    end
  end

  describe '.synthetic?' do
    it 'returns false for explicit contracts' do
      expect(WithContractContract.synthetic?).to be(false)
    end

    it 'returns true for synthetic contracts' do
      contract = Apiwork::Contract::Base.find_contract_for_representation(OrphanRepresentation)
      expect(contract.synthetic?).to be(true)
    end

    it 'returns false for Contract::Base' do
      expect(Apiwork::Contract::Base.synthetic?).to be(false)
    end
  end
end
