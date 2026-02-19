# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Route generation', type: :integration do
  let(:routes) { Apiwork::API::Router.draw }

  describe 'resource routes' do
    it 'routes CRUD actions under API namespace' do
      index = routes.recognize_path('/api/v1/invoices', method: :get)
      show = routes.recognize_path('/api/v1/invoices/1', method: :get)
      create = routes.recognize_path('/api/v1/invoices', method: :post)
      update = routes.recognize_path('/api/v1/invoices/1', method: :patch)
      destroy = routes.recognize_path('/api/v1/invoices/1', method: :delete)

      expect(index[:controller]).to eq('api/v1/invoices')
      expect(index[:action]).to eq('index')
      expect(show[:action]).to eq('show')
      expect(create[:action]).to eq('create')
      expect(update[:action]).to eq('update')
      expect(destroy[:action]).to eq('destroy')
    end
  end

  describe 'singular resource routes' do
    it 'routes without id segment' do
      show = routes.recognize_path('/api/v1/profile', method: :get)
      update = routes.recognize_path('/api/v1/profile', method: :patch)

      expect(show[:controller]).to eq('api/v1/profiles')
      expect(show[:action]).to eq('show')
      expect(show).not_to have_key(:id)
      expect(update[:action]).to eq('update')
    end
  end

  describe 'action restrictions' do
    context 'with only' do
      it 'routes allowed actions' do
        index = routes.recognize_path('/api/v1/restricted_invoices', method: :get)
        show = routes.recognize_path('/api/v1/restricted_invoices/1', method: :get)

        expect(index[:action]).to eq('index')
        expect(show[:action]).to eq('show')
      end

      it 'excludes restricted actions' do
        result = routes.recognize_path('/api/v1/restricted_invoices', method: :post)

        expect(result[:controller]).to eq('apiwork/errors')
        expect(result[:action]).to eq('not_found')
      end
    end

    context 'with except' do
      it 'routes allowed actions' do
        index = routes.recognize_path('/api/v1/safe_items', method: :get)
        create = routes.recognize_path('/api/v1/safe_items', method: :post)

        expect(index[:action]).to eq('index')
        expect(create[:action]).to eq('create')
      end

      it 'excludes restricted actions' do
        result = routes.recognize_path('/api/v1/safe_items/1', method: :delete)

        expect(result[:controller]).to eq('apiwork/errors')
        expect(result[:action]).to eq('not_found')
      end
    end
  end

  describe 'custom member actions' do
    it 'routes under id segment' do
      result = routes.recognize_path('/api/v1/invoices/1/send_invoice', method: :patch)

      expect(result[:controller]).to eq('api/v1/invoices')
      expect(result[:action]).to eq('send_invoice')
      expect(result[:id]).to eq('1')
    end
  end

  describe 'custom collection actions' do
    it 'routes without id segment' do
      search = routes.recognize_path('/api/v1/invoices/search', method: :get)
      bulk_create = routes.recognize_path('/api/v1/invoices/bulk_create', method: :post)

      expect(search[:controller]).to eq('api/v1/invoices')
      expect(search[:action]).to eq('search')
      expect(search).not_to have_key(:id)
      expect(bulk_create[:action]).to eq('bulk_create')
    end
  end

  describe 'nested resource routes' do
    it 'routes under parent with parent id' do
      result = routes.recognize_path('/api/v1/invoices/1/items', method: :get)

      expect(result[:controller]).to eq('api/v1/items')
      expect(result[:action]).to eq('index')
      expect(result[:invoice_id]).to eq('1')
    end
  end

  describe 'path format' do
    it 'transforms paths to kebab case' do
      result = routes.recognize_path('/api/format-test/customer-addresses', method: :get)

      expect(result[:controller]).to eq('api/format_test/customer_addresses')
      expect(result[:action]).to eq('index')
    end
  end

  describe 'catch-all route' do
    it 'routes unmatched paths to error handler' do
      result = routes.recognize_path('/api/v1/nonexistent', method: :get)

      expect(result[:controller]).to eq('apiwork/errors')
      expect(result[:action]).to eq('not_found')
    end
  end
end
