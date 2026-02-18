# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod advanced type schema generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Zod.new(path) }
  let(:output) { generator.generate }

  describe 'Discriminated unions' do
    it 'generates AdjustmentNestedPayloadSchema with z.discriminatedUnion' do
      expect(output).to include("AdjustmentNestedPayloadSchema = z.discriminatedUnion('OP'")
    end

    it 'generates ItemNestedPayloadSchema with z.discriminatedUnion' do
      expect(output).to include("ItemNestedPayloadSchema = z.discriminatedUnion('OP'")
    end

    it 'includes variant schemas in discriminated union' do
      expect(output).to match(
        /AdjustmentNestedPayloadSchema = z\.discriminatedUnion\('OP', \[.*AdjustmentNestedCreatePayloadSchema/m,
      )
    end
  end

  describe 'Literal types' do
    it 'generates z.literal for create OP field' do
      expect(output).to match(/OP: z\.literal\('create'\)/)
    end

    it 'generates z.literal for update OP field' do
      expect(output).to match(/OP: z\.literal\('update'\)/)
    end

    it 'generates z.literal for delete OP field' do
      expect(output).to match(/OP: z\.literal\('delete'\)/)
    end
  end

  describe 'Simple unions' do
    it 'generates InvoiceStatusFilterSchema with z.union' do
      expect(output).to include('InvoiceStatusFilterSchema = z.union([')
    end

    it 'generates PaymentMethodFilterSchema with z.union' do
      expect(output).to include('PaymentMethodFilterSchema = z.union([')
    end
  end

  describe 'Type extends' do
    it 'generates ErrorResponseBodySchema as alias for ErrorSchema' do
      expect(output).to include('ErrorResponseBodySchema = ErrorSchema;')
    end
  end

  describe 'Recursive types with z.lazy' do
    it 'generates ActivityFilterSchema with z.lazy' do
      expect(output).to include('ActivityFilterSchema: z.ZodType<ActivityFilter> = z.lazy(')
    end

    it 'generates InvoiceFilterSchema with z.lazy' do
      expect(output).to include('InvoiceFilterSchema: z.ZodType<InvoiceFilter> = z.lazy(')
    end

    it 'generates CustomerFilterSchema with z.lazy' do
      expect(output).to include('CustomerFilterSchema: z.ZodType<CustomerFilter> = z.lazy(')
    end

    it 'includes self-referencing AND field in recursive schema' do
      expect(output).to match(/AND: z\.array\(ActivityFilterSchema\)/)
    end

    it 'includes self-referencing NOT field in recursive schema' do
      expect(output).to match(/NOT: ActivityFilterSchema/)
    end

    it 'includes type annotation for recursive schemas' do
      expect(output).to match(/: z\.ZodType<\w+> = z\.lazy/)
    end
  end

  describe 'Min and max constraints' do
    it 'generates min constraint on pagination size' do
      expect(output).to match(/size: z\.number\(\)\.int\(\)\.min\(1\)/)
    end

    it 'generates max constraint on pagination size' do
      expect(output).to match(/size: z\.number\(\)\.int\(\)\.min\(1\)\.max\(200\)/)
    end

    it 'generates min constraint on pagination number' do
      expect(output).to match(/number: z\.number\(\)\.int\(\)\.min\(1\)/)
    end
  end

  describe 'UUID validation' do
    it 'generates z.uuid() for uuid-formatted fields' do
      expect(output).to include('z.uuid()')
    end
  end
end
