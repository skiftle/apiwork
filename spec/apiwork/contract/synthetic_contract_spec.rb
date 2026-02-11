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

  let(:caller_api_class) { double('ApiClass') }

  let(:caller_contract) do
    api = caller_api_class
    Class.new(Apiwork::Contract::Base) do
      def self.name
        'CallerContract'
      end

      @api_class = api
    end
  end

  before do
    stub_const('OrphanRepresentation', representation_without_contract)
    stub_const('WithContractRepresentation', representation_with_contract)
    stub_const('WithContractContract', explicit_contract)
    stub_const('CallerContract', caller_contract)
  end

  after do
    Apiwork::Contract::Base.synthetic_contracts.clear
  end

  describe '.contract_for' do
    context 'when explicit contract exists' do
      it 'returns the explicit contract' do
        contract = Apiwork::Contract::Base.contract_for(WithContractRepresentation)
        expect(contract).to eq(WithContractContract)
      end

      it 'does not create synthetic contract' do
        Apiwork::Contract::Base.contract_for(WithContractRepresentation)
        expect(Apiwork::Contract::Base.synthetic_contracts).to be_empty
      end
    end

    context 'when no explicit contract exists' do
      it 'creates a synthetic contract' do
        contract = CallerContract.contract_for(OrphanRepresentation)
        expect(contract).to be_present
        expect(contract).to be < Apiwork::Contract::Base
      end

      it 'caches the synthetic contract' do
        first_call = CallerContract.contract_for(OrphanRepresentation)
        second_call = CallerContract.contract_for(OrphanRepresentation)
        expect(first_call).to equal(second_call)
      end

      it 'sets representation_class on synthetic contract' do
        contract = CallerContract.contract_for(OrphanRepresentation)
        expect(contract.representation_class).to eq(OrphanRepresentation)
      end

      it 'inherits api_class from caller contract' do
        contract = CallerContract.contract_for(OrphanRepresentation)
        expect(contract.api_class).to eq(caller_api_class)
      end

      it 'synthetic contract is anonymous (no name)' do
        contract = CallerContract.contract_for(OrphanRepresentation)
        expect(contract.name).to be_nil
      end
    end

    context 'when representation has no name' do
      it 'returns nil' do
        anonymous_representation = Class.new(Apiwork::Representation::Base)
        contract = Apiwork::Contract::Base.contract_for(anonymous_representation)
        expect(contract).to be_nil
      end
    end

    context 'when representation is nil' do
      it 'returns nil' do
        contract = Apiwork::Contract::Base.contract_for(nil)
        expect(contract).to be_nil
      end
    end
  end

  describe '.synthetic?' do
    it 'returns false for explicit contracts' do
      expect(WithContractContract.synthetic?).to be(false)
    end

    it 'returns true for synthetic contracts' do
      contract = CallerContract.contract_for(OrphanRepresentation)
      expect(contract.synthetic?).to be(true)
    end

    it 'returns false for Contract::Base' do
      expect(Apiwork::Contract::Base.synthetic?).to be(false)
    end
  end
end
