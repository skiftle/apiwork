# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI path generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::OpenAPI.new(path) }
  let(:spec) { generator.generate }

  describe 'Invoice paths' do
    it 'generates collection path' do
      expect(spec[:paths]).to have_key('/invoices')
    end

    it 'generates member path' do
      expect(spec[:paths]).to have_key('/invoices/{id}')
    end

    it 'generates CRUD operations' do
      expect(spec[:paths]['/invoices']).to have_key('get')
      expect(spec[:paths]['/invoices']).to have_key('post')
      expect(spec[:paths]['/invoices/{id}']).to have_key('get')
      expect(spec[:paths]['/invoices/{id}']).to have_key('patch')
      expect(spec[:paths]['/invoices/{id}']).to have_key('delete')
    end
  end

  describe 'Nested item paths' do
    it 'generates nested collection path' do
      nested_path = spec[:paths].keys.find { |key| key.include?('items') && key.include?('invoice') }

      expect(nested_path).not_to be_nil
    end
  end

  describe 'Custom action paths' do
    it 'generates send_invoice member action path' do
      expect(spec[:paths]).to have_key('/invoices/{id}/send_invoice')
    end

    it 'generates void member action path' do
      expect(spec[:paths]).to have_key('/invoices/{id}/void')
    end

    it 'generates search collection action path' do
      expect(spec[:paths]).to have_key('/invoices/search')
    end

    it 'generates bulk_create collection action path' do
      expect(spec[:paths]).to have_key('/invoices/bulk_create')
    end
  end

  describe 'Restricted resource paths' do
    it 'generates restricted_invoices collection path' do
      expect(spec[:paths]).to have_key('/restricted_invoices')
    end

    it 'generates restricted_invoices member path' do
      expect(spec[:paths]).to have_key('/restricted_invoices/{id}')
    end

    it 'includes only get operations on restricted resources' do
      expect(spec[:paths]['/restricted_invoices']['get']).to have_key(:operationId)
      expect(spec[:paths]['/restricted_invoices/{id}']['get']).to have_key(:operationId)
      expect(spec[:paths]['/restricted_invoices']).not_to have_key('post')
    end
  end

  describe 'Singular resource path' do
    it 'generates profile path without id' do
      expect(spec[:paths]).to have_key('/profile')
    end
  end

  describe 'Other resource paths' do
    it 'generates paths for payments' do
      expect(spec[:paths]).to have_key('/payments')
    end

    it 'generates paths for customers' do
      expect(spec[:paths]).to have_key('/customers')
    end

    it 'generates paths for services' do
      expect(spec[:paths]).to have_key('/services')
    end
  end

  describe 'V2 kebab paths' do
    let(:generator) { Apiwork::Export::OpenAPI.new('/api/v2') }

    it 'generates kebab-case paths' do
      expect(spec[:paths]).to have_key('/customer-addresses')
    end
  end
end
