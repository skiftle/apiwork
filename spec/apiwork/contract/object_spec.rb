# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Object do
  describe '#array' do
    it 'defines an array param' do
      contract_class = create_test_contract
      object = described_class.new(contract_class)
      object.array(:tags) do
        string
      end

      expect(object.params[:tags][:type]).to eq(:array)
    end
  end

  describe '#param' do
    it 'registers the param' do
      contract_class = create_test_contract
      object = described_class.new(contract_class)
      object.param(:title, type: :string)

      expect(object.params[:title][:name]).to eq(:title)
      expect(object.params[:title][:type]).to eq(:string)
    end
  end

  describe '#string' do
    it 'defines a string param' do
      contract_class = create_test_contract
      object = described_class.new(contract_class)
      object.string(:title)

      expect(object.params[:title][:type]).to eq(:string)
    end
  end

  describe '#string?' do
    it 'defines an optional string param' do
      contract_class = create_test_contract
      object = described_class.new(contract_class)
      object.string?(:title)

      expect(object.params[:title][:type]).to eq(:string)
      expect(object.params[:title][:optional]).to be(true)
    end
  end
end
