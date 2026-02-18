# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI schema generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::OpenAPI.new(path) }
  let(:spec) { generator.generate }

  describe 'Component schemas' do
    it 'generates invoice schema in components' do
      expect(spec[:components][:schemas]).to have_key('invoice')
    end

    it 'generates payment schema in components' do
      expect(spec[:components][:schemas]).to have_key('payment')
    end

    it 'generates invoice schema as object type' do
      invoice_schema = spec[:components][:schemas]['invoice']

      expect(invoice_schema[:type]).to eq('object')
    end

    it 'generates invoice schema with expected properties' do
      invoice_schema = spec[:components][:schemas]['invoice']

      expect(invoice_schema[:properties].keys).to include('number', 'status', 'created_at')
    end

    it 'generates payment schema with expected properties' do
      payment_schema = spec[:components][:schemas]['payment']

      expect(payment_schema[:properties].keys).to include('amount', 'method', 'status')
    end
  end

  describe 'Enum schemas' do
    it 'includes enum values for status properties' do
      invoice_schema = spec[:components][:schemas]['invoice']
      status_prop = invoice_schema[:properties]['status']

      expect(status_prop[:enum]).to eq(%w[draft sent paid overdue void])
    end
  end

  describe 'Custom type schemas' do
    it 'generates error schema' do
      expect(spec[:components][:schemas]).to have_key('error')
    end

    it 'generates filter schemas as components' do
      expect(spec[:components][:schemas]).to have_key('invoice_filter')
    end
  end

  describe 'Nullable properties' do
    it 'generates nullable type for notes field' do
      invoice_schema = spec[:components][:schemas]['invoice']
      notes_prop = invoice_schema[:properties]['notes']

      expect(notes_prop[:type]).to include('null')
    end
  end

  describe 'Description and example' do
    it 'includes description on profile schema' do
      profile_schema = spec[:components][:schemas]['profile']

      expect(profile_schema[:description]).to eq('Billing profile with personal settings')
    end

    it 'includes example on receipt schema' do
      receipt_schema = spec[:components][:schemas]['receipt']

      expect(receipt_schema[:example]).to eq({ id: 1, number: 'INV-001' })
    end
  end

  describe 'Payload schemas' do
    it 'generates invoice create payload schema' do
      expect(spec[:components][:schemas]).to have_key('invoice_create_payload')
    end

    it 'generates invoice update payload schema' do
      expect(spec[:components][:schemas]).to have_key('invoice_update_payload')
    end
  end

  describe 'Filter schemas' do
    it 'generates invoice filter schema' do
      expect(spec[:components][:schemas]).to have_key('invoice_filter')
    end

    it 'generates payment filter schema' do
      expect(spec[:components][:schemas]).to have_key('payment_filter')
    end
  end

  describe 'Sort schemas' do
    it 'generates invoice sort schema' do
      expect(spec[:components][:schemas]).to have_key('invoice_sort')
    end
  end

  describe 'JSON serialization' do
    it 'generates serializable output' do
      json = JSON.generate(spec)
      parsed = JSON.parse(json)

      expect(parsed['openapi']).to eq('3.1.0')
    end
  end
end
