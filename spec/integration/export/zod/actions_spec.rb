# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod action schema generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Zod.new(path) }
  let(:output) { generator.generate }

  describe 'Request schemas' do
    it 'generates create request body schema' do
      expect(output).to include('InvoicesCreateRequestBodySchema')
    end

    it 'generates update request body schema' do
      expect(output).to include('InvoicesUpdateRequestBodySchema')
    end

    it 'generates index request schema' do
      expect(output).to include('InvoicesIndexRequestSchema')
    end

    it 'generates create request schema' do
      expect(output).to include('InvoicesCreateRequestSchema')
    end

    it 'generates index request query schema' do
      expect(output).to include('InvoicesIndexRequestQuerySchema')
    end
  end

  describe 'Response schemas' do
    it 'generates index response schema' do
      expect(output).to include('InvoicesIndexResponseSchema')
    end

    it 'generates show response schema' do
      expect(output).to include('InvoicesShowResponseSchema')
    end

    it 'generates show response body schema' do
      expect(output).to include('InvoicesShowResponseBodySchema')
    end
  end

  describe 'Custom action schemas' do
    it 'generates send_invoice request body schema' do
      expect(output).to include('InvoicesSendInvoiceRequestBodySchema')
    end

    it 'generates send_invoice response body schema' do
      expect(output).to include('InvoicesSendInvoiceResponseBodySchema')
    end

    it 'generates search request query schema' do
      expect(output).to include('InvoicesSearchRequestQuerySchema')
    end

    it 'generates search response body schema' do
      expect(output).to include('InvoicesSearchResponseBodySchema')
    end

    it 'generates void action request body schema' do
      expect(output).to include('InvoicesVoidRequestBodySchema')
    end

    it 'generates bulk_create request body schema' do
      expect(output).to include('InvoicesBulkCreateRequestBodySchema')
    end
  end

  describe 'Destroy response schema' do
    it 'generates destroy response body schema for invoice' do
      expect(output).to include('InvoicesDestroyResponseBodySchema')
    end

    it 'generates destroy response as z.never() for resources without custom response' do
      expect(output).to include('ActivitiesDestroyResponseSchema = z.never()')
    end
  end

  describe 'Payload schemas' do
    it 'generates create payload schema' do
      expect(output).to include('InvoiceCreatePayloadSchema')
    end

    it 'generates update payload schema' do
      expect(output).to include('InvoiceUpdatePayloadSchema')
    end
  end
end
