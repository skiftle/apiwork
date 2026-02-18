# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod enum and type schema generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Zod.new(path) }
  let(:output) { generator.generate }

  describe 'Enum schemas' do
    it 'generates InvoiceStatusSchema with z.enum' do
      expect(output).to include("InvoiceStatusSchema = z.enum(['draft', 'overdue', 'paid', 'sent', 'void'])")
    end

    it 'generates PaymentMethodSchema with z.enum' do
      expect(output).to include("PaymentMethodSchema = z.enum(['bank_transfer', 'cash', 'credit_card'])")
    end

    it 'generates SortDirectionSchema with z.enum' do
      expect(output).to include("SortDirectionSchema = z.enum(['asc', 'desc'])")
    end

    it 'generates PaymentStatusSchema with z.enum' do
      expect(output).to include("PaymentStatusSchema = z.enum(['completed', 'failed', 'pending', 'refunded'])")
    end

    it 'includes enum values sorted alphabetically' do
      expect(output).to match(/z\.enum\(\['bank_transfer', 'cash', 'credit_card'\]\)/)
    end
  end

  describe 'Custom object schemas' do
    it 'generates InvoiceFilterSchema' do
      expect(output).to include('InvoiceFilterSchema')
    end

    it 'generates InvoiceSortSchema' do
      expect(output).to include('InvoiceSortSchema')
    end
  end

  describe 'Inferred enum types' do
    it 'generates TypeScript type for InvoiceStatus' do
      expect(output).to include("export type InvoiceStatus = 'draft' | 'overdue' | 'paid' | 'sent' | 'void'")
    end

    it 'generates TypeScript type for PaymentMethod' do
      expect(output).to include("export type PaymentMethod = 'bank_transfer' | 'cash' | 'credit_card'")
    end
  end
end
