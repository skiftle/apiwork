# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collection wrapper types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }

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
end
