# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Action::Response do
  describe '#body' do
    it 'defines the body' do
      contract_class = create_test_contract
      response = described_class.new(contract_class, :show)
      response.body do
        string :title
      end

      expect(response.body.params[:title][:type]).to eq(:string)
    end

    it 'returns nil when not set' do
      contract_class = create_test_contract
      response = described_class.new(contract_class, :show)

      expect(response.body).to be_nil
    end
  end

  describe '#no_content!' do
    it 'marks the response as no content' do
      contract_class = create_test_contract
      response = described_class.new(contract_class, :destroy)
      response.no_content!

      expect(response.no_content?).to be(true)
    end
  end

  describe '#no_content?' do
    it 'returns true when no content' do
      contract_class = create_test_contract
      response = described_class.new(contract_class, :destroy)
      response.no_content!

      expect(response.no_content?).to be(true)
    end

    it 'returns false when not no content' do
      contract_class = create_test_contract
      response = described_class.new(contract_class, :show)

      expect(response.no_content?).to be(false)
    end
  end
end
