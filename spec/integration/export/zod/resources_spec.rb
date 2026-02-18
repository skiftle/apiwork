# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod resource schema generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Zod.new(path) }
  let(:output) { generator.generate }

  describe 'Resource schemas' do
    it 'generates InvoiceSchema' do
      expect(output).to include('export const InvoiceSchema')
    end

    it 'generates ItemSchema' do
      expect(output).to include('export const ItemSchema')
    end

    it 'generates CustomerSchema' do
      expect(output).to include('export const CustomerSchema')
    end

    it 'generates PaymentSchema' do
      expect(output).to include('export const PaymentSchema')
    end

    it 'generates ReceiptSchema' do
      expect(output).to include('export const ReceiptSchema')
    end

    it 'generates schemas with z.object' do
      expect(output).to include('z.object(')
    end
  end

  describe 'Zod field types' do
    it 'generates string fields with z.string()' do
      expect(output).to include('z.string()')
    end

    it 'generates boolean fields with z.boolean()' do
      expect(output).to include('z.boolean()')
    end

    it 'generates number fields with z.number()' do
      expect(output).to include('z.number()')
    end

    it 'generates integer fields with z.number().int()' do
      expect(output).to include('z.number().int()')
    end

    it 'generates date fields with z.iso.date()' do
      expect(output).to include('z.iso.date()')
    end

    it 'generates datetime fields with z.iso.datetime()' do
      expect(output).to include('z.iso.datetime()')
    end
  end

  describe 'Nullable fields' do
    it 'generates nullable fields with .nullable()' do
      expect(output).to include('.nullable()')
    end
  end

  describe 'Optional fields' do
    it 'generates optional fields with .optional()' do
      expect(output).to include('.optional()')
    end
  end

  describe 'Array fields' do
    it 'generates array schemas with z.array()' do
      expect(output).to include('z.array(')
    end
  end

  describe 'Zod import' do
    it 'includes zod import statement' do
      expect(output).to match(/import \{ z \} from ['"]zod['"]/)
    end
  end

  describe 'Inferred types' do
    it 'generates TypeScript interfaces alongside schemas' do
      expect(output).to include('export interface Invoice')
    end
  end
end
