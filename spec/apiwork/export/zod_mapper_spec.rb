# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::ZodMapper do
  let(:export) { stub_export }
  let(:mapper) { described_class.new(export) }

  describe '#map_primitive' do
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

  describe '#map_format_to_zod' do
    it 'maps email to z.email()' do
      param = build_param(format: :email, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.email()')
    end

    it 'maps uuid format to z.uuid()' do
      param = build_param(format: :uuid, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.uuid()')
    end

    it 'maps url to z.url()' do
      param = build_param(format: :url, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.url()')
    end

    it 'maps ipv4 to z.ipv4()' do
      param = build_param(format: :ipv4, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.ipv4()')
    end

    it 'maps ipv6 to z.ipv6()' do
      param = build_param(format: :ipv6, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.ipv6()')
    end

    it 'maps date format to z.iso.date()' do
      param = build_param(format: :date, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.iso.date()')
    end

    it 'maps datetime format to z.iso.datetime()' do
      param = build_param(format: :datetime, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.iso.datetime()')
    end

    it 'maps password to z.string()' do
      param = build_param(format: :password, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.string()')
    end

    it 'maps hostname to z.string()' do
      param = build_param(format: :hostname, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.string()')
    end

    it 'maps int32 to z.number().int()' do
      param = build_param(format: :int32, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.number().int()')
    end

    it 'maps float to z.number()' do
      param = build_param(format: :float, type: :string)

      expect(mapper.map_primitive(param)).to eq('z.number()')
    end
  end

  describe '#map_field' do
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
  end

  describe '#map_param' do
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

  describe '#build_object_schema' do
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
  end

  describe '#build_union_schema' do
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

    it 'injects discriminator tag via .extend' do
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
  end

  describe '#build_enum_schemas (via build_enum_type pattern)' do
    it 'builds sorted z.enum schema' do
      invoice_status_enum = build_enum(values: %w[paid draft sent])
      export_with_enums = stub_export(enums: { invoice_status: invoice_status_enum })
      mapper_with_surface = described_class.new(export_with_enums)
      surface = Struct.new(:types, :enums).new({}, { invoice_status: invoice_status_enum })

      result = mapper_with_surface.map(surface)

      expect(result).to include("InvoiceStatusSchema = z.enum(['draft', 'paid', 'sent'])")
    end
  end

  describe '#action_type_name' do
    it 'generates standard action type name' do
      result = mapper.action_type_name(:invoices, :create, 'RequestBody')

      expect(result).to eq('InvoicesCreateRequestBody')
    end

    it 'generates action type name with parent identifiers' do
      result = mapper.action_type_name(:items, :index, 'Request', parent_identifiers: ['invoices'])

      expect(result).to eq('InvoicesItemsIndexRequest')
    end
  end
end
