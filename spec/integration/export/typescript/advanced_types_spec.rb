# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript advanced type generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  describe 'Discriminated unions' do
    it 'generates AdjustmentNestedPayload as union type' do
      expect(output).to include(
        'export type AdjustmentNestedPayload = ' \
        'AdjustmentNestedCreatePayload | AdjustmentNestedUpdatePayload | AdjustmentNestedDeletePayload',
      )
    end

    it 'generates ItemNestedPayload as union type' do
      expect(output).to include(
        'export type ItemNestedPayload = ' \
        'ItemNestedCreatePayload | ItemNestedUpdatePayload | ItemNestedDeletePayload',
      )
    end
  end

  describe 'Literal types' do
    it 'generates create literal on AdjustmentNestedCreatePayload' do
      interface = extract_interface(output, 'AdjustmentNestedCreatePayload')

      expect(interface).to match(/OP\?: 'create'/)
    end

    it 'generates update literal on AdjustmentNestedUpdatePayload' do
      interface = extract_interface(output, 'AdjustmentNestedUpdatePayload')

      expect(interface).to match(/OP\?: 'update'/)
    end

    it 'generates delete literal on AdjustmentNestedDeletePayload' do
      interface = extract_interface(output, 'AdjustmentNestedDeletePayload')

      expect(interface).to match(/OP\?: 'delete'/)
    end
  end

  describe 'Simple unions' do
    it 'generates InvoiceStatusFilter as union without discriminator' do
      expect(output).to include('export type InvoiceStatusFilter = InvoiceStatus |')
    end

    it 'generates PaymentMethodFilter as union without discriminator' do
      expect(output).to include('export type PaymentMethodFilter = PaymentMethod |')
    end
  end

  describe 'Type extends' do
    it 'generates ErrorResponseBody as type alias for Error' do
      expect(output).to include('export type ErrorResponseBody = Error;')
    end
  end

  describe 'Recursive types' do
    it 'generates ActivityFilter with self-referencing AND field' do
      interface = extract_interface(output, 'ActivityFilter')

      expect(interface).to match(/AND\?: ActivityFilter\[\]/)
    end

    it 'generates ActivityFilter with self-referencing NOT field' do
      interface = extract_interface(output, 'ActivityFilter')

      expect(interface).to match(/NOT\?: ActivityFilter/)
    end

    it 'generates ActivityFilter with self-referencing OR field' do
      interface = extract_interface(output, 'ActivityFilter')

      expect(interface).to match(/OR\?: ActivityFilter\[\]/)
    end

    it 'generates InvoiceFilter with self-referencing fields' do
      interface = extract_interface(output, 'InvoiceFilter')

      expect(interface).to match(/AND\?: InvoiceFilter\[\]/)
    end
  end

  private

  def extract_interface(output, name)
    pattern = /export interface #{name}\s*\{[^}]*\}/m
    match_data = output.match(pattern)
    match_data ? match_data[0] : ''
  end
end
