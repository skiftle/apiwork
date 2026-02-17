# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Action::Request do
  describe '#body' do
    it 'defines the body' do
      contract_class = create_test_contract
      request = described_class.new(contract_class, :create)
      request.body do
        string :title
      end

      expect(request.body.params[:title][:type]).to eq(:string)
    end
  end

  describe '#query' do
    it 'defines the query' do
      contract_class = create_test_contract
      request = described_class.new(contract_class, :index)
      request.query do
        string? :title
      end

      expect(request.query.params[:title][:type]).to eq(:string)
    end
  end
end
