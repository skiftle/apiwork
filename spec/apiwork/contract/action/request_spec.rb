# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Action::Request do
  describe '#description' do
    it 'returns the description' do
      contract_class = create_test_contract
      request = described_class.new(contract_class, :create)
      request.description 'The invoice to create'

      expect(request.description).to eq('The invoice to create')
    end

    it 'returns nil when not set' do
      contract_class = create_test_contract
      request = described_class.new(contract_class, :create)

      expect(request.description).to be_nil
    end
  end

  describe '#body' do
    it 'defines a body' do
      contract_class = create_test_contract
      request = described_class.new(contract_class, :create)
      request.body do
        string :title
      end

      expect(request.body.params[:title][:type]).to eq(:string)
    end
  end

  describe '#query' do
    it 'defines a query' do
      contract_class = create_test_contract
      request = described_class.new(contract_class, :index)
      request.query do
        string? :title
      end

      expect(request.query.params[:title][:type]).to eq(:string)
    end
  end
end
