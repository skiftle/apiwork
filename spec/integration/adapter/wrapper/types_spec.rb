# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Wrapper types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }

  describe 'member response body' do
    let(:body) { types[:invoice_show_success_response_body] }

    it 'has type object' do
      expect(body.type).to eq(:object)
    end

    it 'has singular root key as reference' do
      param = body.shape[:invoice]

      expect(param.type).to eq(:reference)
      expect(param.reference).to eq(:invoice)
      expect(param.optional?).to be(false)
    end

    it 'has optional meta object' do
      param = body.shape[:meta]

      expect(param.type).to eq(:object)
      expect(param.optional?).to be(true)
    end
  end

  describe 'collection response body' do
    let(:body) { types[:invoice_index_success_response_body] }

    it 'has type object' do
      expect(body.type).to eq(:object)
    end

    it 'has plural root key as array of references' do
      param = body.shape[:invoices]

      expect(param.type).to eq(:array)
      expect(param.of.type).to eq(:reference)
      expect(param.of.reference).to eq(:invoice)
      expect(param.optional?).to be(false)
    end

    it 'has optional meta object' do
      param = body.shape[:meta]

      expect(param.type).to eq(:object)
      expect(param.optional?).to be(true)
    end
  end

  describe 'create response body' do
    let(:body) { types[:invoice_create_success_response_body] }

    it 'has singular root key as reference' do
      param = body.shape[:invoice]

      expect(param.type).to eq(:reference)
      expect(param.reference).to eq(:invoice)
    end

    it 'has optional meta object' do
      expect(body.shape[:meta].optional?).to be(true)
    end
  end

  describe 'update response body' do
    let(:body) { types[:invoice_update_success_response_body] }

    it 'has singular root key as reference' do
      param = body.shape[:invoice]

      expect(param.type).to eq(:reference)
      expect(param.reference).to eq(:invoice)
    end
  end

  describe 'custom action response body' do
    it 'has send_invoice response body' do
      body = types[:invoice_send_invoice_success_response_body]

      expect(body.type).to eq(:object)
      expect(body.shape).to have_key(:invoice)
    end

    it 'has void response body' do
      body = types[:invoice_void_success_response_body]

      expect(body.type).to eq(:object)
      expect(body.shape).to have_key(:invoice)
    end

    it 'has search collection response body' do
      body = types[:invoice_search_success_response_body]

      expect(body.type).to eq(:object)
      expect(body.shape).to have_key(:invoices)
    end

    it 'has bulk_create collection response body' do
      body = types[:invoice_bulk_create_success_response_body]

      expect(body.type).to eq(:object)
      expect(body.shape).to have_key(:invoices)
    end
  end

  describe 'error response body' do
    let(:body) { types[:error_response_body] }

    it 'has type object' do
      expect(body.type).to eq(:object)
    end

    it 'extends error type' do
      expect(body.extends?).to be(true)
      expect(body.extends).to include(:error)
    end
  end

  describe 'singular resource response body' do
    let(:body) { types[:profile_show_success_response_body] }

    it 'has singular root key' do
      expect(body.shape).to have_key(:profile)
      expect(body.shape[:profile].type).to eq(:reference)
    end
  end
end
