# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::TypeScriptMapper do
  describe '#action_type_name' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'generates standard action type name' do
      result = mapper.action_type_name(:invoices, :create, 'RequestBody')

      expect(result).to eq('InvoicesCreateRequestBody')
    end

    it 'generates action type name with parent identifiers' do
      result = mapper.action_type_name(:items, :index, 'Request', parent_identifiers: ['invoices'])

      expect(result).to eq('InvoicesItemsIndexRequest')
    end

    it 'generates action type name with multiple parent identifiers' do
      result = mapper.action_type_name(:adjustments, :create, 'RequestBody', parent_identifiers: %w[invoices items])

      expect(result).to eq('InvoicesItemsAdjustmentsCreateRequestBody')
    end
  end

  describe '#build_action_request_body_type' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds interface with body parameters' do
      body_params = {
        amount: build_param(type: :decimal),
        number: build_param(type: :string),
      }

      result = mapper.build_action_request_body_type(:invoices, :create, body_params)

      expect(result).to include('export interface InvoicesCreateRequestBody {')
      expect(result).to include('  amount: number;')
      expect(result).to include('  number: string;')
    end
  end

  describe '#build_action_request_query_type' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds interface with query parameters' do
      query_params = {
        page: build_param(optional: true, type: :integer),
        search: build_param(optional: true, type: :string),
      }

      result = mapper.build_action_request_query_type(:invoices, :index, query_params)

      expect(result).to include('export interface InvoicesIndexRequestQuery {')
      expect(result).to include('  page?: number;')
      expect(result).to include('  search?: string;')
    end
  end

  describe '#build_action_request_type' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds interface with query and body nested types' do
      request = {
        body: { name: build_param(type: :string) },
        query: { page: build_param(type: :integer) },
      }

      result = mapper.build_action_request_type(:invoices, :create, request)

      expect(result).to include('export interface InvoicesCreateRequest {')
      expect(result).to include('  query: InvoicesCreateRequestQuery;')
      expect(result).to include('  body: InvoicesCreateRequestBody;')
    end

    it 'builds interface with query only' do
      request = {
        body: {},
        query: { page: build_param(type: :integer) },
      }

      result = mapper.build_action_request_type(:invoices, :index, request)

      expect(result).to include('  query: InvoicesIndexRequestQuery;')
      expect(result).not_to include('body:')
    end

    it 'builds interface with body only' do
      request = {
        body: { name: build_param(type: :string) },
        query: {},
      }

      result = mapper.build_action_request_type(:invoices, :create, request)

      expect(result).to include('  body: InvoicesCreateRequestBody;')
      expect(result).not_to include('query:')
    end
  end

  describe '#build_action_response_body_type' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds type alias for response body' do
      response_body = build_param(shape: { id: { type: :integer } }, type: :object)

      result = mapper.build_action_response_body_type(:invoices, :show, response_body)

      expect(result).to include('export type InvoicesShowResponseBody =')
    end
  end

  describe '#build_action_response_type' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds interface with body property' do
      response = { body: build_param(type: :string) }

      result = mapper.build_action_response_type(:invoices, :show, response)

      expect(result).to include('export interface InvoicesShowResponse {')
      expect(result).to include('  body: InvoicesShowResponseBody;')
    end
  end

  describe '#build_enum_type' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds sorted enum type' do
      enum = build_enum(values: %w[paid draft sent])

      result = mapper.build_enum_type(:invoice_status, enum)

      expect(result).to eq("export type InvoiceStatus = 'draft' | 'paid' | 'sent';")
    end

    it 'uses PascalCase for enum name' do
      enum = build_enum(values: %w[asc desc])

      result = mapper.build_enum_type(:sort_direction, enum)

      expect(result).to include('export type SortDirection')
    end

    it 'includes JSDoc description' do
      enum = build_enum(description: 'Sorting direction', values: %w[asc desc])

      result = mapper.build_enum_type(:sort_direction, enum)

      expect(result).to include('/** Sorting direction */')
    end
  end

  describe '#build_interface' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds interface with properties' do
      type = build_type(
        shape: {
          amount: { type: :decimal },
          number: { type: :string },
        },
      )

      result = mapper.build_interface(:invoice, type)

      expect(result).to include('export interface Invoice {')
      expect(result).to include('  amount: number;')
      expect(result).to include('  number: string;')
    end

    it 'builds interface with extends' do
      type = build_type(
        extends: [:base_record],
        shape: { name: { type: :string } },
      )

      result = mapper.build_interface(:extended_record, type)

      expect(result).to include('export interface ExtendedRecord extends BaseRecord {')
      expect(result).to include('  name: string;')
    end

    it 'builds type alias for extends-only without properties' do
      type = build_type(extends: [:base_record], shape: {})

      result = mapper.build_interface(:simple_record, type)

      expect(result).to eq('export type SimpleRecord = BaseRecord;')
    end

    it 'includes JSDoc description' do
      type = build_type(
        description: 'An invoice record',
        shape: { name: { type: :string } },
      )

      result = mapper.build_interface(:invoice, type)

      expect(result).to include('/** An invoice record */')
    end

    it 'includes JSDoc example' do
      type = build_type(
        description: 'An invoice',
        example: 'INV-001',
        shape: { name: { type: :string } },
      )

      result = mapper.build_interface(:invoice, type)

      expect(result).to include('@example "INV-001"')
    end

    it 'builds interface with multiple extends' do
      type = build_type(
        extends: [:base_record, :timestamped],
        shape: { name: { type: :string } },
      )

      result = mapper.build_interface(:full_record, type)

      expect(result).to include('export interface FullRecord extends BaseRecord, Timestamped {')
      expect(result).to include('  name: string;')
    end
  end

  describe '#build_union_type' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds union type with sorted variants' do
      type = build_union_type(
        variants: [
          { type: :string },
          { type: :integer },
        ],
      )

      result = mapper.build_union_type(:mixed, type)

      expect(result).to eq('export type Mixed = string | number;')
    end

    context 'when variant lacks discriminator in shape' do
      it 'injects discriminator tag' do
        invoice_type = build_type(shape: { number: { type: :string } })
        export_with_types = stub_export(types: { invoice: invoice_type })
        mapper_with_types = described_class.new(export_with_types)

        type = build_union_type(
          discriminator: :kind,
          variants: [
            { reference: :invoice, tag: 'invoice', type: :reference },
          ],
        )

        result = mapper_with_types.build_union_type(:tagged, type)

        expect(result).to include("{ kind: 'invoice' } & Invoice")
      end
    end

    context 'when discriminator exists in referenced shape' do
      it 'skips tag injection' do
        invoice_type = build_type(shape: { kind: { type: :string } })
        export_with_types = stub_export(types: { invoice: invoice_type })
        mapper_with_types = described_class.new(export_with_types)

        type = build_union_type(
          discriminator: :kind,
          variants: [
            { reference: :invoice, tag: 'invoice', type: :reference },
          ],
        )

        result = mapper_with_types.build_union_type(:tagged, type)

        expect(result).to eq('export type Tagged = Invoice;')
      end
    end

    it 'includes JSDoc description' do
      type = build_union_type(
        description: 'A mixed type',
        variants: [{ type: :string }],
      )

      result = mapper.build_union_type(:mixed, type)

      expect(result).to include('/** A mixed type */')
    end

    it 'builds discriminated union with multiple variants' do
      invoice_type = build_type(shape: { number: { type: :string } })
      payment_type = build_type(shape: { amount: { type: :decimal } })
      export_with_types = stub_export(types: { invoice: invoice_type, payment: payment_type })
      mapper_with_types = described_class.new(export_with_types)

      type = build_union_type(
        discriminator: :kind,
        variants: [
          { reference: :invoice, tag: 'invoice', type: :reference },
          { reference: :payment, tag: 'payment', type: :reference },
        ],
      )

      result = mapper_with_types.build_union_type(:tagged, type)

      expect(result).to include("{ kind: 'invoice' } & Invoice")
      expect(result).to include("{ kind: 'payment' } & Payment")
    end
  end

  describe '#format_example' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'formats string value with quotes' do
      expect(mapper.format_example('INV-001')).to eq('"INV-001"')
    end

    it 'formats numeric value as string' do
      expect(mapper.format_example(42)).to eq('42')
    end

    it 'formats hash as JSON' do
      expect(mapper.format_example({ key: 'value' })).to eq('{"key":"value"}')
    end

    it 'formats array as JSON' do
      expect(mapper.format_example([1, 2, 3])).to eq('[1,2,3]')
    end
  end

  describe '#jsdoc' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'returns nil without description or example' do
      expect(mapper.jsdoc).to be_nil
    end

    it 'returns single-line JSDoc for description only' do
      expect(mapper.jsdoc(description: 'An invoice')).to eq('/** An invoice */')
    end

    it 'returns multi-line JSDoc for description and example' do
      result = mapper.jsdoc(description: 'An invoice', example: 'INV-001')

      expect(result).to include('/**')
      expect(result).to include(' * An invoice')
      expect(result).to include(' * @example "INV-001"')
      expect(result).to include(' */')
    end

    it 'returns multi-line JSDoc for example only' do
      result = mapper.jsdoc(example: 'INV-001')

      expect(result).to include('/**')
      expect(result).to include(' * @example "INV-001"')
      expect(result).to include(' */')
    end
  end

  describe '#map_field' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    context 'with nullable param' do
      it 'prepends null in sorted order' do
        param = build_param(nullable: true, type: :string)

        expect(mapper.map_field(param)).to eq('null | string')
      end
    end

    context 'with nullable reference' do
      it 'prepends null in sorted order' do
        invoice_type = build_type(shape: { number: { type: :string } })
        export_with_types = stub_export(types: { invoice: invoice_type })
        mapper_with_types = described_class.new(export_with_types)

        param = build_param(nullable: true, reference: :invoice, type: :reference)

        expect(mapper_with_types.map_field(param)).to eq('Invoice | null')
      end
    end

    context 'with inline enum' do
      it 'returns sorted values as union' do
        param = build_param(enum: %w[paid draft sent], type: :string)

        expect(mapper.map_field(param)).to eq("'draft' | 'paid' | 'sent'")
      end
    end

    context 'with enum reference' do
      it 'returns PascalCase enum name' do
        invoice_status_enum = build_enum(values: %w[draft sent paid])
        export_with_enums = stub_export(enums: { invoice_status: invoice_status_enum })
        mapper_with_enums = described_class.new(export_with_enums)

        param = build_param(enum: :invoice_status, type: :string)

        expect(mapper_with_enums.map_field(param)).to eq('InvoiceStatus')
      end
    end

    context 'with nullable enum' do
      it 'returns sorted union with null' do
        param = build_param(enum: %w[draft sent], nullable: true, type: :string)

        expect(mapper.map_field(param)).to eq("'draft' | 'sent' | null")
      end
    end
  end

  describe '#map_param' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    context 'with object type' do
      it 'returns Record for empty shape' do
        param = build_param(shape: {}, type: :object)

        expect(mapper.map_param(param)).to eq('Record<string, unknown>')
      end

      it 'returns inline object with properties' do
        param = build_param(
          shape: {
            count: { type: :integer },
            name: { type: :string },
          },
          type: :object,
        )

        expect(mapper.map_param(param)).to eq('{ count: number; name: string }')
      end

      context 'with partial object' do
        it 'marks fields as optional' do
          param = build_param(
            partial: true,
            shape: {
              name: { type: :string },
            },
            type: :object,
          )

          expect(mapper.map_param(param)).to eq('{ name?: string }')
        end
      end
    end

    context 'with array type' do
      it 'returns typed array' do
        param = build_param(of: { type: :string }, shape: {}, type: :array)

        expect(mapper.map_param(param)).to eq('string[]')
      end

      it 'returns unknown array for untyped' do
        param = build_param(of: nil, shape: {}, type: :array)

        expect(mapper.map_param(param)).to eq('unknown[]')
      end

      it 'wraps union element in parentheses' do
        param = build_param(
          of: {
            discriminator: nil,
            type: :union,
            variants: [{ type: :string }, { type: :integer }],
          },
          shape: {},
          type: :array,
        )

        expect(mapper.map_param(param)).to eq('(number | string)[]')
      end

      it 'returns inline object array for shape without of' do
        param = build_param(
          of: nil,
          shape: {
            name: { type: :string },
          },
          type: :array,
        )

        expect(mapper.map_param(param)).to eq('{ name: string }[]')
      end
    end

    context 'with union type' do
      it 'returns sorted variants' do
        param = build_param(
          discriminator: nil,
          type: :union,
          variants: [
            { type: :string },
            { type: :integer },
          ],
        )

        expect(mapper.map_param(param)).to eq('number | string')
      end
    end

    context 'with literal type' do
      it 'maps string literal' do
        param = build_param(type: :literal, value: 'create')

        expect(mapper.map_param(param)).to eq("'create'")
      end

      it 'maps number literal' do
        param = build_param(type: :literal, value: 42)

        expect(mapper.map_param(param)).to eq('42')
      end

      it 'maps boolean literal' do
        param = build_param(type: :literal, value: true)

        expect(mapper.map_param(param)).to eq('true')
      end

      it 'maps nil literal' do
        param = build_param(type: :literal, value: nil)

        expect(mapper.map_param(param)).to eq('null')
      end

      it 'maps false literal' do
        param = build_param(type: :literal, value: false)

        expect(mapper.map_param(param)).to eq('false')
      end
    end

    context 'with reference type' do
      it 'returns PascalCase name' do
        invoice_type = build_type(shape: { number: { type: :string } })
        export_with_types = stub_export(types: { invoice: invoice_type })
        mapper_with_types = described_class.new(export_with_types)

        param = build_param(reference: :invoice, type: :reference)

        expect(mapper_with_types.map_param(param)).to eq('Invoice')
      end
    end
  end

  describe '#map_primitive' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'maps string to string' do
      param = build_param(type: :string)

      expect(mapper.map_primitive(param)).to eq('string')
    end

    it 'maps integer to number' do
      param = build_param(type: :integer)

      expect(mapper.map_primitive(param)).to eq('number')
    end

    it 'maps number to number' do
      param = build_param(type: :number)

      expect(mapper.map_primitive(param)).to eq('number')
    end

    it 'maps decimal to number' do
      param = build_param(type: :decimal)

      expect(mapper.map_primitive(param)).to eq('number')
    end

    it 'maps boolean to boolean' do
      param = build_param(type: :boolean)

      expect(mapper.map_primitive(param)).to eq('boolean')
    end

    it 'maps date to string' do
      param = build_param(type: :date)

      expect(mapper.map_primitive(param)).to eq('string')
    end

    it 'maps datetime to string' do
      param = build_param(type: :datetime)

      expect(mapper.map_primitive(param)).to eq('string')
    end

    it 'maps time to string' do
      param = build_param(type: :time)

      expect(mapper.map_primitive(param)).to eq('string')
    end

    it 'maps uuid to string' do
      param = build_param(type: :uuid)

      expect(mapper.map_primitive(param)).to eq('string')
    end

    it 'maps binary to string' do
      param = build_param(type: :binary)

      expect(mapper.map_primitive(param)).to eq('string')
    end

    it 'maps unknown to unknown' do
      param = build_param(type: :unknown)

      expect(mapper.map_primitive(param)).to eq('unknown')
    end
  end
end
