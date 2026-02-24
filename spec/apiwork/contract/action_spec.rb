# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Action do
  describe '#deprecated!' do
    it 'marks the action as deprecated' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)
      action.deprecated!

      expect(action.deprecated?).to be(true)
    end
  end

  describe '#deprecated?' do
    it 'returns true when deprecated' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)
      action.deprecated!

      expect(action.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)

      expect(action.deprecated?).to be(false)
    end
  end

  describe '#description' do
    it 'returns the description' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)
      action.description 'Creates a new invoice'

      expect(action.description).to eq('Creates a new invoice')
    end

    it 'returns nil when not set' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)

      expect(action.description).to be_nil
    end
  end

  describe '#operation_id' do
    it 'returns the operation ID' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)
      action.operation_id 'createInvoice'

      expect(action.operation_id).to eq('createInvoice')
    end

    it 'returns nil when not set' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)

      expect(action.operation_id).to be_nil
    end
  end

  describe '#raises' do
    it 'registers the error codes' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :show)
      action.raises :not_found, :forbidden

      expect(action.raises).to eq(%i[not_found forbidden])
    end

    it 'raises ConfigurationError for non-symbol' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :show)

      expect do
        action.raises 404
      end.to raise_error(Apiwork::ConfigurationError, /raises must be symbols/)
    end
  end

  describe '#request' do
    it 'returns the request' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)

      expect(action.request).to be_a(Apiwork::Contract::Action::Request)
    end
  end

  describe '#response' do
    it 'returns the response' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)

      expect(action.response).to be_a(Apiwork::Contract::Action::Response)
    end
  end

  describe '#summary' do
    it 'returns the summary' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)
      action.summary 'Create a new invoice'

      expect(action.summary).to eq('Create a new invoice')
    end

    it 'returns nil when not set' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)

      expect(action.summary).to be_nil
    end
  end

  describe '#tags' do
    it 'returns the tags' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)
      action.tags :billing, :invoices

      expect(action.tags).to eq(%i[billing invoices])
    end

    it 'returns nil when not set' do
      contract_class = create_test_contract
      action = described_class.new(contract_class, :create)

      expect(action.tags).to be_nil
    end
  end
end
