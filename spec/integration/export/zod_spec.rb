# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod export', type: :integration do
  let(:generator) { Apiwork::Export::Zod.new('/api/v1') }
  let(:output) { generator.generate }

  describe 'output format' do
    it 'imports from zod' do
      expect(output).to match(/import \{ z \} from ['"]zod['"]/)
    end

    it 'generates schema definitions using z.object' do
      expect(output).to include('z.object(')
    end

    it 'exports schemas with export const' do
      expect(output).to include('export const')
    end

    it 'also generates TypeScript interfaces' do
      expect(output).to include('export interface')
    end

    it 'properly closes all parentheses' do
      open_parens = output.scan(/\(/).count
      close_parens = output.scan(/\)/).count

      expect(open_parens).to eq(close_parens)
    end
  end

  describe 'resource schemas' do
    it 'generates Invoice schema' do
      expect(output).to include('export const InvoiceSchema')
    end

    it 'generates Payment schema' do
      expect(output).to include('export const PaymentSchema')
    end

    it 'generates Customer schema' do
      expect(output).to include('export const CustomerSchema')
    end
  end

  describe 'property types' do
    it 'generates string properties with z.string()' do
      expect(output).to include('z.string()')
    end

    it 'generates boolean properties with z.boolean()' do
      expect(output).to include('z.boolean()')
    end

    it 'generates number properties with z.number()' do
      expect(output).to include('z.number()')
    end

    it 'generates optional properties' do
      expect(output).to include('.optional()')
    end

    it 'generates nullable properties' do
      expect(output).to include('.nullable()')
    end
  end

  describe 'array types' do
    it 'generates array schemas' do
      expect(output).to include('z.array(')
    end
  end

  describe 'enum types' do
    it 'generates InvoiceStatus enum schema' do
      expect(output).to include("InvoiceStatusSchema = z.enum(['draft', 'overdue', 'paid', 'sent', 'void'])")
    end

    it 'generates PaymentMethod enum schema' do
      expect(output).to include("PaymentMethodSchema = z.enum(['bank_transfer', 'cash', 'credit_card'])")
    end

    it 'generates PaymentStatus enum schema' do
      expect(output).to include("PaymentStatusSchema = z.enum(['completed', 'failed', 'pending', 'refunded'])")
    end

    it 'generates SortDirection enum schema' do
      expect(output).to include("SortDirectionSchema = z.enum(['asc', 'desc'])")
    end
  end

  describe 'request and response schemas' do
    it 'generates request types' do
      expect(output).to include('InvoicesIndexRequest')
    end

    it 'generates response types' do
      expect(output).to include('InvoicesIndexResponse')
    end
  end

  describe 'filter schemas' do
    it 'generates filter schemas for invoices' do
      expect(output).to include('InvoiceFilterSchema')
    end

    it 'generates filter schemas for payments' do
      expect(output).to include('PaymentFilterSchema')
    end
  end

  describe 'payload schemas' do
    it 'generates create payload schemas' do
      expect(output).to include('InvoiceCreatePayloadSchema')
    end

    it 'generates update payload schemas' do
      expect(output).to include('InvoiceUpdatePayloadSchema')
    end
  end
end
