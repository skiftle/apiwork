# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript resource generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  describe 'Resource interfaces' do
    it 'generates Invoice interface' do
      expect(output).to include('export interface Invoice')
    end

    it 'generates Item interface' do
      expect(output).to include('export interface Item')
    end

    it 'generates Customer type' do
      expect(output).to include('export type Customer =')
    end

    it 'generates Payment interface' do
      expect(output).to include('export interface Payment')
    end

    it 'generates Receipt interface' do
      expect(output).to include('export interface Receipt')
    end
  end

  describe 'Property types' do
    it 'generates string properties' do
      expect(output).to match(/number: string/)
    end

    it 'generates boolean properties' do
      expect(output).to match(/sent: boolean/)
    end

    it 'generates datetime properties as string' do
      expect(output).to match(/created_at: string/)
    end

    it 'generates nullable date properties as string' do
      expect(output).to match(/due_on: null \| string/)
    end

    it 'generates nullable number properties for decimal fields' do
      expect(output).to match(/unit_price: null \| number/)
    end

    it 'generates nullable number properties for integer fields' do
      expect(output).to match(/quantity: null \| number/)
    end
  end

  describe 'Nullable fields' do
    it 'generates nullable string as union with null' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/notes: null \| string/)
    end

    it 'generates nullable email on person customer' do
      person_customer_interface = extract_interface(output, 'PersonCustomer')

      expect(person_customer_interface).to match(/email: null \| string/)
    end
  end

  describe 'Optional fields' do
    it 'generates optional associations with question mark' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/items\?: Item\[\]/)
    end
  end

  describe 'Enum attribute types' do
    it 'generates status field with enum type reference' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/status: InvoiceStatus/)
    end

    it 'generates method field with enum type reference on payment' do
      payment_interface = extract_interface(output, 'Payment')

      expect(payment_interface).to match(/method: PaymentMethod/)
    end
  end

  describe 'Association types' do
    it 'generates has_many associations as arrays' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/items\?: Item\[\]/)
    end

    it 'generates belongs_to associations as single reference' do
      payment_interface = extract_interface(output, 'Payment')

      expect(payment_interface).to match(/invoice\?: Invoice/)
    end

    it 'generates has_one associations as single reference' do
      person_customer_interface = extract_interface(output, 'PersonCustomer')

      expect(person_customer_interface).to match(/address\?: Address/)
    end
  end

  describe 'STI types' do
    it 'generates PersonCustomer interface' do
      expect(output).to include('PersonCustomer')
    end

    it 'generates CompanyCustomer interface' do
      expect(output).to include('CompanyCustomer')
    end
  end

  private

  def extract_interface(output, name)
    pattern = /export interface #{name}\s*\{[^}]*\}/m
    match_data = output.match(pattern)
    match_data ? match_data[0] : ''
  end
end
