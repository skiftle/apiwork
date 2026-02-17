# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Request do
  describe '#initialize' do
    it 'creates with required attributes' do
      request = described_class.new(body: { title: 'First Post' }, query: { page: 1 })

      expect(request.body).to eq({ title: 'First Post' })
      expect(request.query).to eq({ page: 1 })
    end
  end

  describe '#transform' do
    it 'returns the transformed request' do
      request = described_class.new(body: { title: 'First Post' }, query: { page: 1 })

      result = request.transform { |data| data.transform_keys(&:to_s) }

      expect(result).to be_a(described_class)
      expect(result.body).to eq({ 'title' => 'First Post' })
      expect(result.query).to eq({ 'page' => 1 })
    end
  end

  describe '#transform_body' do
    it 'returns the request with transformed body' do
      request = described_class.new(body: { title: 'First Post' }, query: { page: 1 })

      result = request.transform_body { |data| data.transform_keys(&:to_s) }

      expect(result.body).to eq({ 'title' => 'First Post' })
      expect(result.query).to eq({ page: 1 })
    end
  end

  describe '#transform_query' do
    it 'returns the request with transformed query' do
      request = described_class.new(body: { title: 'First Post' }, query: { page: 1 })

      result = request.transform_query { |data| data.transform_keys(&:to_s) }

      expect(result.body).to eq({ title: 'First Post' })
      expect(result.query).to eq({ 'page' => 1 })
    end
  end
end
