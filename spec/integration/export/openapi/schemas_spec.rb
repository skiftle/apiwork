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

  describe '$ref references' do
    it 'generates $ref for association in resource schema' do
      invoice_schema = spec[:components][:schemas]['invoice']

      expect(invoice_schema[:properties]['items'][:items]).to eq({ '$ref': '#/components/schemas/item' })
    end

    it 'generates $ref for belongs_to association' do
      payment_schema = spec[:components][:schemas]['payment']

      expect(payment_schema[:properties]['invoice']).to eq({ '$ref': '#/components/schemas/invoice' })
    end

    it 'generates $ref for response body schema' do
      show_op = spec[:paths]['/invoices/{id}']['get']
      response_schema = show_op[:responses][:'200'][:content][:'application/json'][:schema]

      expect(response_schema).to eq({ '$ref': '#/components/schemas/invoice_show_success_response_body' })
    end

    it 'generates $ref for payload in request body' do
      create_op = spec[:paths]['/invoices']['post']
      body_schema = create_op[:requestBody][:content][:'application/json'][:schema]

      expect(body_schema[:properties]['invoice']).to eq({ '$ref': '#/components/schemas/invoice_create_payload' })
    end
  end

  describe 'Required fields' do
    it 'includes required array on resource schema' do
      invoice_schema = spec[:components][:schemas]['invoice']

      expect(invoice_schema[:required]).to include('id', 'number', 'created_at')
    end

    it 'includes required array on payload schema' do
      payload = spec[:components][:schemas]['invoice_create_payload']

      expect(payload[:required]).to include('customer_id', 'number')
    end

    it 'excludes optional fields from required array' do
      payload = spec[:components][:schemas]['invoice_create_payload']

      expect(payload[:required]).not_to include('notes', 'sent')
    end
  end

  describe 'Format annotations' do
    it 'generates date format for date fields' do
      invoice_schema = spec[:components][:schemas]['invoice']

      expect(invoice_schema[:properties]['due_on'][:format]).to eq('date')
    end

    it 'generates date-time format for datetime fields' do
      invoice_schema = spec[:components][:schemas]['invoice']

      expect(invoice_schema[:properties]['created_at'][:format]).to eq('date-time')
    end

    it 'generates uuid format for uuid fields' do
      profile_schema = spec[:components][:schemas]['profile']

      expect(profile_schema[:properties]['external_id'][:format]).to eq('uuid')
    end

    it 'generates time format for time fields' do
      profile_schema = spec[:components][:schemas]['profile']

      expect(profile_schema[:properties]['preferred_contact_time'][:format]).to eq('time')
    end
  end
end
