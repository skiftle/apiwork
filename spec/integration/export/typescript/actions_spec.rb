# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript action type generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  describe 'Request types' do
    it 'generates create request body type' do
      expect(output).to include('InvoicesCreateRequestBody')
    end

    it 'generates update request body type' do
      expect(output).to include('InvoicesUpdateRequestBody')
    end

    it 'generates index request type' do
      expect(output).to include('InvoicesIndexRequest')
    end

    it 'generates create request type' do
      expect(output).to include('InvoicesCreateRequest')
    end

    it 'generates index request query type' do
      expect(output).to include('InvoicesIndexRequestQuery')
    end
  end

  describe 'Response types' do
    it 'generates index response type' do
      expect(output).to include('InvoicesIndexResponse')
    end

    it 'generates show response type' do
      expect(output).to include('InvoicesShowResponse')
    end

    it 'generates show response body type' do
      expect(output).to include('InvoicesShowResponseBody')
    end
  end

  describe 'Custom action types' do
    it 'generates send_invoice request body type' do
      expect(output).to include('InvoicesSendInvoiceRequestBody')
    end

    it 'generates send_invoice response body type' do
      expect(output).to include('InvoicesSendInvoiceResponseBody')
    end

    it 'generates search request query type' do
      expect(output).to include('InvoicesSearchRequestQuery')
    end

    it 'generates search response body type' do
      expect(output).to include('InvoicesSearchResponseBody')
    end

    it 'generates void action request body type' do
      expect(output).to include('InvoicesVoidRequestBody')
    end

    it 'generates bulk_create request body type' do
      expect(output).to include('InvoicesBulkCreateRequestBody')
    end
  end

  describe 'Destroy response type' do
    it 'generates destroy response body type for invoice' do
      expect(output).to include('InvoicesDestroyResponseBody')
    end

    it 'generates destroy response as never for resources without custom response' do
      expect(output).to match(/ActivitiesDestroyResponse = never/)
    end
  end

  describe 'Nested resource action types' do
    it 'generates nested items index request type' do
      expect(output).to include('InvoicesItemsIndexRequest')
    end

    it 'generates nested items create request type' do
      expect(output).to include('InvoicesItemsCreateRequest')
    end
  end

  describe 'Payload types' do
    it 'generates create payload' do
      expect(output).to include('InvoiceCreatePayload')
    end

    it 'generates update payload' do
      expect(output).to include('InvoiceUpdatePayload')
    end
  end
end
