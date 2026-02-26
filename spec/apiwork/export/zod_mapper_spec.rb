# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::ZodMapper do
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

  describe '#build_action_request_body_schema' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds z.object schema for body parameters' do
      body_params = {
        amount: build_param(type: :decimal),
        number: build_param(type: :string),
      }

      result = mapper.build_action_request_body_schema(:invoices, :create, body_params)

      expect(result).to include('InvoicesCreateRequestBodySchema = z.object({')
      expect(result).to include('  amount: z.number()')
      expect(result).to include('  number: z.string()')
    end
  end

  describe '#build_action_request_query_schema' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds z.object schema for query parameters' do
      query_params = {
        page: build_param(optional: true, type: :integer),
        search: build_param(optional: true, type: :string),
      }

      result = mapper.build_action_request_query_schema(:invoices, :index, query_params)

      expect(result).to include('InvoicesIndexRequestQuerySchema = z.object({')
      expect(result).to include('  page: z.number().int().optional()')
      expect(result).to include('  search: z.string().optional()')
    end
  end

  describe '#build_action_request_schema' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds z.object schema with query and body nested schemas' do
      request = {
        body: { name: build_param(type: :string) },
        query: { page: build_param(type: :integer) },
      }

      result = mapper.build_action_request_schema(:invoices, :create, request)

      expect(result).to include('InvoicesCreateRequestSchema = z.object({')
      expect(result).to include('  query: InvoicesCreateRequestQuerySchema')
      expect(result).to include('  body: InvoicesCreateRequestBodySchema')
    end

    it 'builds schema with query only' do
      request = {
        body: {},
        query: { page: build_param(type: :integer) },
      }

      result = mapper.build_action_request_schema(:invoices, :index, request)

      expect(result).to include('  query: InvoicesIndexRequestQuerySchema')
      expect(result).not_to include('body:')
    end

    it 'builds schema with body only' do
      request = {
        body: { name: build_param(type: :string) },
        query: {},
      }

      result = mapper.build_action_request_schema(:invoices, :create, request)

      expect(result).to include('  body: InvoicesCreateRequestBodySchema')
      expect(result).not_to include('query:')
    end
  end

  describe '#build_action_response_body_schema' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds schema for response body' do
      response_body = build_param(shape: { id: { type: :integer } }, type: :object)

      result = mapper.build_action_response_body_schema(:invoices, :show, response_body)

      expect(result).to include('InvoicesShowResponseBodySchema = z.object({ id: z.number().int() })')
    end
  end

  describe '#build_action_response_schema' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds success-only schema when no raises' do
      response = stub_response

      result = mapper.build_action_response_schema(:invoices, :show, response, raises: [])

      expect(result).to eq('export const InvoicesShowResponseSchema = z.object({ status: z.literal(200), body: InvoicesShowResponseBodySchema });')
    end

    it 'builds no content schema' do
      response = stub_response(no_content: true)

      result = mapper.build_action_response_schema(:invoices, :destroy, response, raises: [])

      expect(result).to eq('export const InvoicesDestroyResponseSchema = z.object({ status: z.literal(204) });')
    end

    it 'builds discriminated union with error statuses' do
      export_with_errors = stub_export(error_codes: { unprocessable_entity: stub_error_code(status: 422) })
      mapper_with_errors = described_class.new(export_with_errors)
      response = stub_response

      result = mapper_with_errors.build_action_response_schema(:invoices, :create, response, raises: [:unprocessable_entity])

      expect(result).to include("z.discriminatedUnion('status'")
      expect(result).to include('z.object({ status: z.literal(200), body: InvoicesCreateResponseBodySchema })')
      expect(result).to include('z.object({ status: z.literal(422), body: ErrorSchema })')
    end
  end

  describe '#build_object_schema' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds z.object schema' do
      type = build_type(
        shape: {
          amount: { type: :decimal },
          number: { type: :string },
        },
      )

      result = mapper.build_object_schema(:invoice, type)

      expect(result).to include('export const InvoiceSchema = z.object({')
      expect(result).to include('  amount: z.number()')
      expect(result).to include('  number: z.string()')
    end

    it 'builds extended schema with .extend()' do
      type = build_type(
        extends: [:base_record],
        shape: { name: { type: :string } },
      )

      result = mapper.build_object_schema(:extended_record, type)

      expect(result).to include('BaseRecordSchema.extend({')
    end

    it 'builds alias for extends-only without properties' do
      type = build_type(extends: [:base_record], shape: {})

      result = mapper.build_object_schema(:simple_record, type)

      expect(result).to eq('export const SimpleRecordSchema = BaseRecordSchema;')
    end

    it 'builds merged schema for multiple extends' do
      type = build_type(extends: [:base_record, :timestamped], shape: {})

      result = mapper.build_object_schema(:full_record, type)

      expect(result).to eq('export const FullRecordSchema = BaseRecordSchema.merge(TimestampedSchema);')
    end

    it 'builds recursive schema with z.lazy' do
      type = build_type(
        shape: {
          name: { type: :string },
        },
      )

      result = mapper.build_object_schema(:invoice, type, recursive: true)

      expect(result).to include(': z.ZodType<Invoice>')
      expect(result).to include('z.lazy(() => z.object({')
    end

    it 'builds merged and extended schema for multiple extends with properties' do
      type = build_type(extends: [:base_record, :timestamped], shape: { name: { type: :string } })

      result = mapper.build_object_schema(:full_record, type)

      expect(result).to include('BaseRecordSchema.merge(TimestampedSchema).extend({')
      expect(result).to include('  name: z.string()')
    end

    it 'wraps in z.lazy when recursive even with extends' do
      type = build_type(
        extends: [:base_record],
        shape: { name: { type: :string } },
      )

      result = mapper.build_object_schema(:recursive_record, type, recursive: true)

      expect(result).to include(': z.ZodType<RecursiveRecord>')
      expect(result).to include('z.lazy(() => z.object({')
    end
  end

  describe '#build_union_schema' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'builds discriminated union' do
      invoice_type = build_type(shape: { number: { type: :string } })
      export_with_types = stub_export(types: { invoice: invoice_type })
      mapper_with_types = described_class.new(export_with_types)

      type = build_union_type(
        discriminator: :kind,
        variants: [
          { reference: :invoice, tag: 'invoice', type: :reference },
        ],
      )

      result = mapper_with_types.build_union_schema(:tagged, type)

      expect(result).to include("z.discriminatedUnion('kind'")
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

        result = mapper_with_types.build_union_schema(:tagged, type)

        expect(result).to include("InvoiceSchema.extend({ kind: z.literal('invoice') })")
      end
    end

    it 'builds recursive union with z.lazy' do
      type = build_union_type(
        variants: [
          { type: :string },
          { type: :integer },
        ],
      )

      result = mapper.build_union_schema(:mixed, type, recursive: true)

      expect(result).to include(': z.ZodType<Mixed>')
      expect(result).to include('z.lazy(() => z.union([')
    end

    it 'builds non-discriminated union' do
      type = build_union_type(
        variants: [
          { type: :string },
          { type: :integer },
        ],
      )

      result = mapper.build_union_schema(:mixed, type)

      expect(result).to include('export const MixedSchema = z.union([')
      expect(result).to include('  z.string()')
      expect(result).to include('  z.number().int()')
    end

    context 'when discriminator exists in referenced shape' do
      it 'skips tag injection' do
        invoice_type = build_type(shape: { kind: { type: :string }, number: { type: :string } })
        export_with_types = stub_export(types: { invoice: invoice_type })
        mapper_with_types = described_class.new(export_with_types)

        type = build_union_type(
          discriminator: :kind,
          variants: [
            { reference: :invoice, tag: 'invoice', type: :reference },
          ],
        )

        result = mapper_with_types.build_union_schema(:tagged, type)

        expect(result).not_to include('.extend')
        expect(result).to include('InvoiceSchema')
      end
    end
  end

  describe '#map_field' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    context 'with nullable modifier' do
      it 'appends .nullable()' do
        param = build_param(nullable: true, type: :string)

        expect(mapper.map_field(param)).to eq('z.string().nullable()')
      end
    end

    context 'with optional modifier' do
      it 'appends .optional()' do
        param = build_param(optional: true, type: :string)

        expect(mapper.map_field(param)).to eq('z.string().optional()')
      end
    end

    context 'with nullable and optional' do
      it 'appends both modifiers' do
        param = build_param(nullable: true, optional: true, type: :string)

        expect(mapper.map_field(param)).to eq('z.string().nullable().optional()')
      end
    end

    context 'with inline enum' do
      it 'returns z.enum()' do
        param = build_param(enum: %w[draft sent paid], type: :string)

        expect(mapper.map_field(param)).to eq("z.enum(['draft', 'sent', 'paid'])")
      end
    end

    context 'with enum reference' do
      it 'returns schema reference' do
        invoice_status_enum = build_enum(values: %w[draft sent paid])
        export_with_enums = stub_export(enums: { invoice_status: invoice_status_enum })
        mapper_with_enums = described_class.new(export_with_enums)

        param = build_param(enum: :invoice_status, type: :string)

        expect(mapper_with_enums.map_field(param)).to eq('InvoiceStatusSchema')
      end
    end

    context 'with reference' do
      it 'returns schema reference with modifiers' do
        invoice_type = build_type(shape: { number: { type: :string } })
        export_with_types = stub_export(types: { invoice: invoice_type })
        mapper_with_types = described_class.new(export_with_types)

        param = build_param(nullable: true, reference: :invoice, type: :reference)

        expect(mapper_with_types.map_field(param)).to eq('InvoiceSchema.nullable()')
      end
    end

    context 'with force_optional false' do
      it 'suppresses optional modifier' do
        param = build_param(optional: true, type: :string)

        expect(mapper.map_field(param, force_optional: false)).to eq('z.string()')
      end
    end

    context 'with force_optional true' do
      it 'forces optional modifier on non-optional param' do
        param = build_param(type: :string)

        expect(mapper.map_field(param, force_optional: true)).to eq('z.string().optional()')
      end
    end
  end

  describe '#map_format_to_zod' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'maps email to z.email()' do
      expect(mapper.map_format_to_zod(:email)).to eq('z.email()')
    end

    it 'maps uuid format to z.uuid()' do
      expect(mapper.map_format_to_zod(:uuid)).to eq('z.uuid()')
    end

    it 'maps url to z.url()' do
      expect(mapper.map_format_to_zod(:url)).to eq('z.url()')
    end

    it 'maps ipv4 to z.ipv4()' do
      expect(mapper.map_format_to_zod(:ipv4)).to eq('z.ipv4()')
    end

    it 'maps ipv6 to z.ipv6()' do
      expect(mapper.map_format_to_zod(:ipv6)).to eq('z.ipv6()')
    end

    it 'maps date format to z.iso.date()' do
      expect(mapper.map_format_to_zod(:date)).to eq('z.iso.date()')
    end

    it 'maps datetime format to z.iso.datetime()' do
      expect(mapper.map_format_to_zod(:datetime)).to eq('z.iso.datetime()')
    end

    it 'maps password to z.string()' do
      expect(mapper.map_format_to_zod(:password)).to eq('z.string()')
    end

    it 'maps hostname to z.string()' do
      expect(mapper.map_format_to_zod(:hostname)).to eq('z.string()')
    end

    it 'maps int32 to z.number().int()' do
      expect(mapper.map_format_to_zod(:int32)).to eq('z.number().int()')
    end

    it 'maps float to z.number()' do
      expect(mapper.map_format_to_zod(:float)).to eq('z.number()')
    end

    it 'maps int64 to z.number().int()' do
      expect(mapper.map_format_to_zod(:int64)).to eq('z.number().int()')
    end

    it 'maps double to z.number()' do
      expect(mapper.map_format_to_zod(:double)).to eq('z.number()')
    end

    it 'maps unknown format to z.string()' do
      expect(mapper.map_format_to_zod(:custom)).to eq('z.string()')
    end
  end

  describe '#map_param' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    context 'with object type' do
      it 'returns z.record for empty shape' do
        param = build_param(shape: {}, type: :object)

        expect(mapper.map_param(param)).to eq('z.record(z.string(), z.unknown())')
      end

      it 'returns z.object with properties' do
        param = build_param(
          shape: {
            count: { type: :integer },
            name: { type: :string },
          },
          type: :object,
        )

        expect(mapper.map_param(param)).to eq('z.object({ count: z.number().int(), name: z.string() })')
      end

      it 'appends .partial() for partial objects' do
        param = build_param(
          partial: true,
          shape: {
            name: { type: :string },
          },
          type: :object,
        )

        expect(mapper.map_param(param)).to eq('z.object({ name: z.string() }).partial()')
      end
    end

    context 'with array type' do
      it 'returns typed array' do
        param = build_param(of: { type: :string }, shape: {}, type: :array)

        expect(mapper.map_param(param)).to eq('z.array(z.string())')
      end

      it 'returns unknown array for untyped' do
        param = build_param(of: nil, shape: {}, type: :array)

        expect(mapper.map_param(param)).to eq('z.array(z.unknown())')
      end

      it 'returns inline object array for shape without of' do
        param = build_param(
          of: nil,
          shape: {
            name: { type: :string },
          },
          type: :array,
        )

        expect(mapper.map_param(param)).to eq('z.array(z.object({ name: z.string() }))')
      end

      it 'appends min and max constraints' do
        param = build_param(max: 10, min: 1, of: { type: :string }, shape: {}, type: :array)

        expect(mapper.map_param(param)).to eq('z.array(z.string()).min(1).max(10)')
      end

      it 'appends min constraint with zero value' do
        param = build_param(max: 5, min: 0, of: { type: :string }, shape: {}, type: :array)

        expect(mapper.map_param(param)).to eq('z.array(z.string()).min(0).max(5)')
      end

      it 'appends min constraint only' do
        param = build_param(min: 1, of: { type: :string }, shape: {}, type: :array)

        expect(mapper.map_param(param)).to eq('z.array(z.string()).min(1)')
      end

      it 'appends max constraint only' do
        param = build_param(max: 10, of: { type: :string }, shape: {}, type: :array)

        expect(mapper.map_param(param)).to eq('z.array(z.string()).max(10)')
      end
    end

    context 'with union type' do
      it 'returns z.union' do
        param = build_param(
          discriminator: nil,
          type: :union,
          variants: [
            { type: :string },
            { type: :integer },
          ],
        )

        expect(mapper.map_param(param)).to eq('z.union([z.string(), z.number().int()])')
      end

      it 'returns z.discriminatedUnion' do
        param = build_param(
          discriminator: :kind,
          type: :union,
          variants: [
            { shape: { kind: { type: :literal, value: 'a' } }, type: :object },
            { shape: { kind: { type: :literal, value: 'b' } }, type: :object },
          ],
        )

        result = mapper.map_param(param)

        expect(result).to include("z.discriminatedUnion('kind'")
      end
    end

    context 'with literal type' do
      it 'maps string literal' do
        param = build_param(type: :literal, value: 'create')

        expect(mapper.map_param(param)).to eq("z.literal('create')")
      end

      it 'maps number literal' do
        param = build_param(type: :literal, value: 42)

        expect(mapper.map_param(param)).to eq('z.literal(42)')
      end

      it 'maps boolean literal' do
        param = build_param(type: :literal, value: true)

        expect(mapper.map_param(param)).to eq('z.literal(true)')
      end

      it 'maps nil literal' do
        param = build_param(type: :literal, value: nil)

        expect(mapper.map_param(param)).to eq('z.null()')
      end

      it 'maps false literal' do
        param = build_param(type: :literal, value: false)

        expect(mapper.map_param(param)).to eq('z.literal(false)')
      end
    end

    context 'with reference type' do
      it 'returns schema reference' do
        invoice_type = build_type(shape: { number: { type: :string } })
        export_with_types = stub_export(types: { invoice: invoice_type })
        mapper_with_types = described_class.new(export_with_types)

        param = build_param(reference: :invoice, type: :reference)

        expect(mapper_with_types.map_param(param)).to eq('InvoiceSchema')
      end
    end
  end

  describe '#map_primitive' do
    let(:export) { stub_export }
    let(:mapper) { described_class.new(export) }

    it 'maps string to z.string()' do
      param = build_param(type: :string)

      expect(mapper.map_primitive(param)).to eq('z.string()')
    end

    it 'maps integer to z.number().int()' do
      param = build_param(type: :integer)

      expect(mapper.map_primitive(param)).to eq('z.number().int()')
    end

    it 'maps number to z.number()' do
      param = build_param(type: :number)

      expect(mapper.map_primitive(param)).to eq('z.number()')
    end

    it 'maps decimal to z.number()' do
      param = build_param(type: :decimal)

      expect(mapper.map_primitive(param)).to eq('z.number()')
    end

    it 'maps boolean to z.boolean()' do
      param = build_param(type: :boolean)

      expect(mapper.map_primitive(param)).to eq('z.boolean()')
    end

    it 'maps date to z.iso.date()' do
      param = build_param(type: :date)

      expect(mapper.map_primitive(param)).to eq('z.iso.date()')
    end

    it 'maps datetime to z.iso.datetime()' do
      param = build_param(type: :datetime)

      expect(mapper.map_primitive(param)).to eq('z.iso.datetime()')
    end

    it 'maps time to z.iso.time()' do
      param = build_param(type: :time)

      expect(mapper.map_primitive(param)).to eq('z.iso.time()')
    end

    it 'maps uuid to z.uuid()' do
      param = build_param(type: :uuid)

      expect(mapper.map_primitive(param)).to eq('z.uuid()')
    end

    it 'maps binary to z.string()' do
      param = build_param(type: :binary)

      expect(mapper.map_primitive(param)).to eq('z.string()')
    end

    it 'maps unknown to z.unknown()' do
      param = build_param(type: :unknown)

      expect(mapper.map_primitive(param)).to eq('z.unknown()')
    end

    context 'with min and max on boundable types' do
      it 'appends min and max constraints' do
        param = build_param(max: 100, min: 0, type: :integer)

        expect(mapper.map_primitive(param)).to eq('z.number().int().min(0).max(100)')
      end
    end

    context 'with min and max on string' do
      it 'appends min and max constraints' do
        param = build_param(max: 20, min: 3, type: :string)

        expect(mapper.map_primitive(param)).to eq('z.string().min(3).max(20)')
      end
    end
  end
end
