# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript export', type: :integration do
  let(:generator) { Apiwork::Export::TypeScript.new('/api/v1') }
  let(:output) { generator.generate }

  describe 'output format' do
    it 'generates valid TypeScript declarations' do
      expect(output).to be_a(String)
      expect(output).to include('export')
    end

    it 'generates interface declarations' do
      expect(output).to include('export interface')
    end

    it 'generates type declarations for enums' do
      expect(output).to match(/export type \w+ = /)
    end

    it 'properly closes all interfaces' do
      open_braces = output.scan(/{/).count
      close_braces = output.scan(/}/).count

      expect(open_braces).to eq(close_braces)
    end
  end

  describe 'resource interfaces' do
    it 'generates Invoice interface' do
      expect(output).to include('export interface Invoice')
    end

    it 'generates Customer interface' do
      expect(output).to include('export interface Customer')
    end

    it 'generates Payment interface' do
      expect(output).to include('export interface Payment')
    end

    it 'generates Item interface' do
      expect(output).to include('export interface Item')
    end
  end

  describe 'property types' do
    it 'generates string properties' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/number: string/)
    end

    it 'generates datetime properties as string' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/created_at: string/)
    end

    it 'generates boolean properties' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/sent: boolean/)
    end

    it 'generates nullable properties' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/notes: null \| string/)
    end
  end

  describe 'association types' do
    it 'generates has_many associations as arrays' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/items\?: Item\[\]/)
    end

    it 'generates belongs_to associations as single reference' do
      payment_interface = extract_interface(output, 'Payment')

      expect(payment_interface).to match(/invoice\?: Invoice/)
    end
  end

  describe 'enum types' do
    it 'generates InvoiceStatus type' do
      expect(output).to include("export type InvoiceStatus = 'draft' | 'overdue' | 'paid' | 'sent' | 'void'")
    end

    it 'generates PaymentMethod type' do
      expect(output).to include("export type PaymentMethod = 'bank_transfer' | 'cash' | 'credit_card'")
    end

    it 'generates PaymentStatus type' do
      expect(output).to include("export type PaymentStatus = 'completed' | 'failed' | 'pending' | 'refunded'")
    end

    it 'generates SortDirection type' do
      expect(output).to include("export type SortDirection = 'asc' | 'desc'")
    end
  end

  describe 'filter types' do
    it 'generates filter interface for invoices' do
      expect(output).to include('export interface InvoiceFilter')
    end

    it 'generates filter interface for payments' do
      expect(output).to include('export interface PaymentFilter')
    end
  end

  describe 'sort types' do
    it 'generates sort interface for invoices' do
      expect(output).to include('export interface InvoiceSort')
    end
  end

  describe 'payload types' do
    it 'generates create payload' do
      expect(output).to include('export interface InvoiceCreatePayload')
    end

    it 'generates update payload' do
      expect(output).to include('export interface InvoiceUpdatePayload')
    end
  end

  describe 'request and response types' do
    it 'generates request types' do
      expect(output).to include('InvoicesIndexRequest')
      expect(output).to include('InvoicesCreateRequest')
    end

    it 'generates response types' do
      expect(output).to include('InvoicesIndexResponse')
      expect(output).to include('InvoicesShowResponse')
    end

    it 'generates request body types' do
      expect(output).to include('InvoicesCreateRequestBody')
    end

    it 'generates request query types' do
      expect(output).to include('InvoicesIndexRequestQuery')
    end
  end

  describe 'nested resource types' do
    it 'generates types for nested items under invoices' do
      expect(output).to include('InvoicesItemsIndexRequest')
    end
  end

  private

  def extract_interface(output, name)
    pattern = /export interface #{name}\s*\{[^}]*\}/m
    match_data = output.match(pattern)
    match_data ? match_data[0] : ''
  end
end
