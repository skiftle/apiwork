# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript enum and type generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  describe 'Enum types' do
    it 'generates InvoiceStatus type' do
      expect(output).to include("export type InvoiceStatus = 'draft' | 'overdue' | 'paid' | 'sent' | 'void'")
    end

    it 'generates PaymentMethod type' do
      expect(output).to include("export type PaymentMethod = 'bank_transfer' | 'cash' | 'credit_card'")
    end

    it 'generates SortDirection type' do
      expect(output).to include("export type SortDirection = 'asc' | 'desc'")
    end

    it 'generates PaymentStatus type' do
      expect(output).to include("export type PaymentStatus = 'completed' | 'failed' | 'pending' | 'refunded'")
    end

    it 'includes enum values sorted alphabetically' do
      expect(output).to match(/InvoiceStatus = 'draft' \| 'overdue' \| 'paid' \| 'sent' \| 'void'/)
    end
  end

  describe 'Custom object types' do
    it 'generates filter types as interfaces' do
      expect(output).to include('export interface InvoiceFilter')
    end

    it 'generates sort types as interfaces' do
      expect(output).to include('export interface InvoiceSort')
    end
  end

  describe 'Type ordering' do
    it 'generates enum types as type aliases' do
      expect(output).to match(/export type \w+ = /)
    end

    it 'generates object types as interfaces' do
      expect(output).to include('export interface')
    end
  end
end
