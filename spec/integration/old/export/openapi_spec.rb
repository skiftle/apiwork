# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI export', type: :integration do
  let(:generator) { Apiwork::Export::OpenAPI.new('/api/v1') }
  let(:spec) { generator.generate }

  describe 'structure' do
    it 'generates OpenAPI 3.1.0' do
      expect(spec[:openapi]).to eq('3.1.0')
    end

    it 'includes paths, components, and info' do
      expect(spec[:paths]).to be_a(Hash)
      expect(spec[:components]).to be_a(Hash)
      expect(spec[:components][:schemas]).to be_a(Hash)
      expect(spec[:info]).to be_a(Hash)
    end

    it 'includes API title and version' do
      expect(spec[:info][:title]).to eq('Billing API')
      expect(spec[:info][:version]).to eq('1.0.0')
    end

    it 'includes summary, terms of service, contact, license, and servers' do
      expect(spec[:info][:summary]).to eq('A billing API for Apiwork')
      expect(spec[:info][:termsOfService]).to eq('https://example.com/terms')
      expect(spec[:info][:contact][:name]).to eq('API Support')
      expect(spec[:info][:license][:name]).to eq('MIT')
      expect(spec[:servers].length).to eq(2)
      expect(spec[:servers][0][:url]).to eq('https://api.example.com')
    end
  end

  describe 'paths' do
    it 'generates paths for invoices resource' do
      expect(spec[:paths]).to have_key('/invoices')
      expect(spec[:paths]).to have_key('/invoices/{id}')
    end

    it 'generates CRUD operations for invoices' do
      expect(spec[:paths]['/invoices']).to have_key('get')
      expect(spec[:paths]['/invoices']).to have_key('post')
      expect(spec[:paths]['/invoices/{id}']).to have_key('get')
      expect(spec[:paths]['/invoices/{id}']).to have_key('patch')
      expect(spec[:paths]['/invoices/{id}']).to have_key('delete')
    end

    it 'generates paths for nested items under invoices' do
      expect(spec[:paths]).to have_key('/{invoice_id}/items')
      expect(spec[:paths]).to have_key('/{invoice_id}/items/{id}')
    end

    it 'generates paths for custom member actions' do
      expect(spec[:paths]).to have_key('/invoices/{id}/send_invoice')
      expect(spec[:paths]).to have_key('/invoices/{id}/void')
    end

    it 'generates paths for custom collection actions' do
      expect(spec[:paths]).to have_key('/invoices/search')
      expect(spec[:paths]).to have_key('/invoices/bulk_create')
    end

    it 'generates paths for payments, customers, and services' do
      expect(spec[:paths]).to have_key('/payments')
      expect(spec[:paths]).to have_key('/customers')
      expect(spec[:paths]).to have_key('/services')
    end
  end

  describe 'operations' do
    it 'generates operationId for each operation' do
      invoices_index = spec[:paths]['/invoices']['get']

      expect(invoices_index[:operationId]).to eq('invoices_index')
    end

    it 'uses custom operationId when specified' do
      invoices_destroy = spec[:paths]['/invoices/{id}']['delete']

      expect(invoices_destroy[:operationId]).to eq('deleteInvoice')
    end

    it 'marks deprecated actions' do
      invoices_destroy = spec[:paths]['/invoices/{id}']['delete']

      expect(invoices_destroy[:deprecated]).to be(true)
    end

    it 'includes tags on tagged actions' do
      invoices_index = spec[:paths]['/invoices']['get']

      expect(invoices_index[:tags]).to include(:invoices, :public)
    end

    it 'includes path parameters for member actions' do
      show_op = spec[:paths]['/invoices/{id}']['get']
      id_param = show_op[:parameters].find { |p| p[:name] == 'id' }

      expect(id_param[:in]).to eq('path')
      expect(id_param[:required]).to be(true)
      expect(id_param[:schema]).to eq({ type: 'string' })
    end

    it 'includes parent path parameters for nested resources' do
      nested_index = spec[:paths]['/{invoice_id}/items']['get']
      parent_param = nested_index[:parameters].find { |p| p[:name] == 'invoice_id' }

      expect(parent_param[:in]).to eq('path')
      expect(parent_param[:required]).to be(true)
    end
  end

  describe 'request and response' do
    it 'generates request body for create and update' do
      create_op = spec[:paths]['/invoices']['post']
      update_op = spec[:paths]['/invoices/{id}']['patch']

      expect(create_op[:requestBody][:content]).to have_key(:'application/json')
      expect(update_op[:requestBody][:content]).to have_key(:'application/json')
    end

    it 'generates 200 response for show action' do
      show_op = spec[:paths]['/invoices/{id}']['get']

      expect(show_op[:responses]).to have_key(:'200')
      expect(show_op[:responses][:'200'][:content]).to have_key(:'application/json')
    end
  end

  describe 'schemas' do
    it 'generates schema for invoice resource' do
      invoice_schema = spec[:components][:schemas]['invoice']

      expect(invoice_schema[:type]).to eq('object')
      expect(invoice_schema[:properties]).to be_a(Hash)
      expect(invoice_schema[:properties].keys).to include('number', 'status', 'created_at')
    end

    it 'generates schema for payment resource' do
      payment_schema = spec[:components][:schemas]['payment']

      expect(payment_schema[:type]).to eq('object')
      expect(payment_schema[:properties].keys).to include('amount', 'method', 'status')
    end

    it 'generates filter schemas' do
      expect(spec[:components][:schemas]).to have_key('invoice_filter')
      expect(spec[:components][:schemas]).to have_key('payment_filter')
    end

    it 'generates sort schemas' do
      expect(spec[:components][:schemas]).to have_key('invoice_sort')
    end

    it 'generates payload schemas' do
      expect(spec[:components][:schemas]).to have_key('invoice_create_payload')
      expect(spec[:components][:schemas]).to have_key('invoice_update_payload')
    end

    it 'includes description on resource type' do
      profile_schema = spec[:components][:schemas]['profile']

      expect(profile_schema[:description]).to eq('Billing profile with personal settings')
    end

    it 'includes example on resource type' do
      receipt_schema = spec[:components][:schemas]['receipt']

      expect(receipt_schema[:example]).to eq({ id: 1, number: 'INV-001' })
    end

    it 'includes enum values for status properties' do
      invoice_schema = spec[:components][:schemas]['invoice']
      status_prop = invoice_schema[:properties]['status']

      expect(status_prop[:enum]).to eq(%w[draft sent paid overdue void])
    end
  end

  describe 'JSON serialization' do
    it 'serializes to valid JSON' do
      json = JSON.generate(spec)
      parsed = JSON.parse(json)

      expect(parsed['openapi']).to eq('3.1.0')
    end
  end
end
