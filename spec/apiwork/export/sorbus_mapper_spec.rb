# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::SorbusMapper do
  describe '.map' do
    it 'generates output with zod import' do
      export = stub_export
      surface = build_surface

      result = described_class.map(export, surface)

      expect(result).to include("import { z } from 'zod';")
    end

    context 'with enums' do
      it 'generates enum schemas' do
        export = stub_export
        surface = build_surface(
          enums: { invoice_status: build_enum(values: %w[draft paid sent]) },
          types: {},
        )

        result = described_class.map(export, surface)

        expect(result).to include("export const InvoiceStatusSchema = z.enum(['draft', 'paid', 'sent']);")
      end
    end

    context 'with types' do
      it 'generates type schemas' do
        export = stub_export
        type = build_type(shape: { amount: { type: :decimal }, number: { type: :string } })
        surface = build_surface(
          enums: {},
          types: { invoice: type },
        )

        result = described_class.map(export, surface)

        expect(result).to include('export const InvoiceSchema = z.object({')
        expect(result).to include('  amount: z.number()')
        expect(result).to include('  number: z.string()')
      end
    end

    context 'with resources' do
      it 'generates contract with endpoints' do
        action_dump = {
          deprecated: false,
          description: nil,
          method: :get,
          operation_id: nil,
          path: '/invoices',
          raises: [],
          request: { body: {}, query: {} },
          response: { body: nil, no_content: false },
          summary: nil,
          tags: [],
        }
        export = stub_export(
          resources: {
            invoices: build_resource(
              actions: { index: action_dump },
              identifier: 'invoices',
            ),
          },
        )
        surface = build_surface

        result = described_class.map(export, surface)

        expect(result).to include('export const contract = {')
        expect(result).to include("method: 'GET'")
        expect(result).to include("path: '/invoices'")
        expect(result).to include('} as const;')
      end
    end

    context 'with path params' do
      it 'extracts path params from path' do
        action_dump = {
          deprecated: false,
          description: nil,
          method: :get,
          operation_id: nil,
          path: '/invoices/:id',
          raises: [],
          request: { body: {}, query: {} },
          response: { body: nil, no_content: false },
          summary: nil,
          tags: [],
        }
        export = stub_export(
          resources: {
            invoices: build_resource(
              actions: { show: action_dump },
              identifier: 'invoices',
            ),
          },
        )
        surface = build_surface

        result = described_class.map(export, surface)

        expect(result).to include('pathParams: z.object({ id: z.string() })')
      end
    end

    context 'with request' do
      it 'references request schema' do
        action_dump = {
          deprecated: false,
          description: nil,
          method: :get,
          operation_id: nil,
          path: '/invoices',
          raises: [],
          request: {
            body: {},
            query: {
              page: { optional: true, type: :integer },
              search: { optional: true, type: :string },
            },
          },
          response: { body: nil, no_content: false },
          summary: nil,
          tags: [],
        }
        export = stub_export(
          resources: {
            invoices: build_resource(
              actions: { index: action_dump },
              identifier: 'invoices',
            ),
          },
        )
        surface = build_surface

        result = described_class.map(export, surface)

        expect(result).to include('query: z.object({ page: z.number().int().optional(), search: z.string().optional() })')
      end
    end

    context 'with response' do
      it 'references response schema' do
        action_dump = {
          deprecated: false,
          description: nil,
          method: :get,
          operation_id: nil,
          path: '/invoices/:id',
          raises: [],
          request: { body: {}, query: {} },
          response: {
            body: { shape: { id: { type: :integer }, number: { type: :string } }, type: :object },
            no_content: false,
          },
          summary: nil,
          tags: [],
        }
        export = stub_export(
          resources: {
            invoices: build_resource(
              actions: { show: action_dump },
              identifier: 'invoices',
            ),
          },
        )
        surface = build_surface

        result = described_class.map(export, surface)

        expect(result).to include('body: z.object({ id: z.number().int(), number: z.string() })')
      end
    end

    context 'with errors' do
      it 'maps raises to status codes' do
        error_code = Struct.new(:status).new(422)
        action_dump = {
          deprecated: false,
          description: nil,
          method: :post,
          operation_id: nil,
          path: '/invoices',
          raises: [:unprocessable_entity],
          request: { body: {}, query: {} },
          response: { body: nil, no_content: false },
          summary: nil,
          tags: [],
        }
        export = stub_export(
          error_codes: { unprocessable_entity: error_code },
          resources: {
            invoices: build_resource(
              actions: { create: action_dump },
              identifier: 'invoices',
            ),
          },
        )
        surface = build_surface

        result = described_class.map(export, surface)

        expect(result).to include('errors: [422]')
      end
    end

    context 'with nested resources' do
      it 'nests endpoints in resource tree' do
        nested_action_dump = {
          deprecated: false,
          description: nil,
          method: :get,
          operation_id: nil,
          path: '/:invoice_id/items',
          raises: [],
          request: { body: {}, query: {} },
          response: { body: nil, no_content: false },
          summary: nil,
          tags: [],
        }
        parent_action_dump = {
          deprecated: false,
          description: nil,
          method: :get,
          operation_id: nil,
          path: '/invoices',
          raises: [],
          request: { body: {}, query: {} },
          response: { body: nil, no_content: false },
          summary: nil,
          tags: [],
        }
        export = stub_export(
          resources: {
            invoices: build_resource(
              actions: { index: parent_action_dump },
              identifier: 'invoices',
              resources: {
                items: {
                  actions: { index: nested_action_dump },
                  identifier: 'items',
                  parent_identifiers: ['invoices'],
                  path: ':invoice_id/items',
                  resources: {},
                },
              },
            ),
          },
        )
        surface = build_surface

        result = described_class.map(export, surface)

        expect(result).to include("path: '/:invoice_id/items'")
      end
    end
  end
end
