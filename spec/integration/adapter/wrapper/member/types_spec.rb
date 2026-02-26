# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Member wrapper types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:resources) { introspection.resources }

  describe 'member response body' do
    let(:body) { resources[:invoices].actions[:show].response.body }

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

  describe 'create response body' do
    let(:body) { resources[:invoices].actions[:create].response.body }

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
    let(:body) { resources[:invoices].actions[:update].response.body }

    it 'has singular root key as reference' do
      param = body.shape[:invoice]

      expect(param.type).to eq(:reference)
      expect(param.reference).to eq(:invoice)
    end
  end

  describe 'custom action response body' do
    it 'has send_invoice response body' do
      body = resources[:invoices].actions[:send_invoice].response.body

      expect(body.type).to eq(:object)
      expect(body.shape).to have_key(:invoice)
    end

    it 'has void response body' do
      body = resources[:invoices].actions[:void].response.body

      expect(body.type).to eq(:object)
      expect(body.shape).to have_key(:invoice)
    end

    it 'has search collection response body' do
      body = resources[:invoices].actions[:search].response.body

      expect(body.type).to eq(:object)
      expect(body.shape).to have_key(:invoices)
    end

    it 'has bulk_create collection response body' do
      body = resources[:invoices].actions[:bulk_create].response.body

      expect(body.type).to eq(:object)
      expect(body.shape).to have_key(:invoices)
    end
  end

  describe 'create request body' do
    let(:body) { resources[:invoices].actions[:create].request.body }

    it 'has invoice param' do
      expect(body).to have_key(:invoice)
    end
  end

  describe 'update request body' do
    let(:body) { resources[:invoices].actions[:update].request.body }

    it 'has invoice param' do
      expect(body).to have_key(:invoice)
    end
  end

  describe 'singular resource response body' do
    let(:body) { resources[:profile].actions[:show].response.body }

    it 'has singular root key' do
      expect(body.shape).to have_key(:profile)
      expect(body.shape[:profile].type).to eq(:reference)
    end
  end
end
