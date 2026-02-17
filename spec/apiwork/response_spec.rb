# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Response do
  describe '#initialize' do
    it 'creates with required attributes' do
      response = described_class.new(body: { title: 'First Post' })

      expect(response.body).to eq({ title: 'First Post' })
    end
  end

  describe '#transform' do
    it 'returns the transformed response' do
      response = described_class.new(body: { title: 'First Post' })

      result = response.transform { |data| data.transform_keys(&:to_s) }

      expect(result).to be_a(described_class)
      expect(result.body).to eq({ 'title' => 'First Post' })
    end
  end

  describe '#transform_body' do
    it 'returns the response with transformed body' do
      response = described_class.new(body: { title: 'First Post' })

      result = response.transform_body { |data| data.transform_keys(&:to_s) }

      expect(result.body).to eq({ 'title' => 'First Post' })
    end
  end
end
