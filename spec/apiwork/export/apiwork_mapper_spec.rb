# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::ApiworkMapper do
  def stub_apiwork_export(enums: {}, error_codes: {}, resources: {}, types: {})
    api_stub = Struct.new(:base_path, :enums, :error_codes, :fingerprint, :info, :locales, :resources, :types)
      .new('/api/v1', enums, error_codes, 'abc123', nil, [:en], resources, types)

    export = Struct.new(:api, :options).new(api_stub, { key_format: :camel })
    export.define_singleton_method(:transform_key, &:to_s)
    export
  end

  describe '.map' do
    it 'includes base path and fingerprint' do
      export = stub_apiwork_export
      surface = build_surface

      result = described_class.map(export, surface)

      expect(result[:base_path]).to eq('/api/v1')
      expect(result[:fingerprint]).to eq('abc123')
    end

    context 'with enums' do
      it 'serializes enums' do
        export = stub_apiwork_export
        surface = build_surface(
          enums: { status: build_enum(values: %w[draft paid sent]) },
          types: {},
        )

        result = described_class.map(export, surface)

        expect(result[:enums]).to contain_exactly(
          a_hash_including(name: 'status', values: %w[draft paid sent]),
        )
      end
    end

    context 'with types' do
      it 'serializes types in topological order' do
        export = stub_apiwork_export

        address_type = build_type(shape: { city: { type: :string } })
        client_type = build_type(shape: { address: { reference: :address, type: :reference } })

        surface = build_surface(
          enums: {},
          types: { address: address_type, client: client_type },
        )

        result = described_class.map(export, surface)

        names = result[:types].map { |type| type[:name] }
        expect(names.index('address')).to be < names.index('client')
      end

      it 'marks recursive types' do
        export = stub_apiwork_export

        filter_type = build_type(
          shape: {
            AND: { of: { reference: :invoice_filter, type: :reference }, optional: true, type: :array },
            NOT: { optional: true, reference: :invoice_filter, type: :reference },
            name: { optional: true, type: :string },
          },
        )

        surface = build_surface(
          enums: {},
          types: { invoice_filter: filter_type },
        )

        result = described_class.map(export, surface)

        filter = result[:types].find { |type| type[:name] == 'invoice_filter' }
        expect(filter[:recursive]).to be true
      end

      it 'marks non-recursive types' do
        export = stub_apiwork_export
        type = build_type(shape: { amount: { type: :decimal } })
        surface = build_surface(enums: {}, types: { invoice: type })

        result = described_class.map(export, surface)

        invoice = result[:types].find { |type| type[:name] == 'invoice' }
        expect(invoice[:recursive]).to be false
      end
    end

    context 'with resources' do
      it 'serializes endpoints' do
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
        export = stub_apiwork_export(
          resources: {
            invoices: build_resource(
              actions: { index: action_dump },
              identifier: 'invoices',
            ),
          },
        )
        surface = build_surface

        result = described_class.map(export, surface)

        invoices = result[:resources].first
        expect(invoices[:name]).to eq('invoices')
        expect(invoices[:actions].first[:method]).to eq('get')
        expect(invoices[:actions].first[:path]).to eq('/invoices')
      end

      it 'serializes nested resources' do
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
        export = stub_apiwork_export(
          resources: {
            invoices: build_resource(
              actions: {},
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

        invoices = result[:resources].first
        items = invoices[:resources].first
        expect(items[:name]).to eq('items')
        expect(items[:actions].first[:path]).to eq('/:invoice_id/items')
      end
    end

    context 'with error codes' do
      it 'serializes error codes' do
        export = stub_apiwork_export(
          error_codes: {
            not_found: Struct.new(:description, :status).new('Not found', 404),
            unprocessable_entity: Struct.new(:description, :status).new('Validation failed', 422),
          },
        )
        surface = build_surface

        result = described_class.map(export, surface)

        expect(result[:error_codes]).to contain_exactly(
          a_hash_including(name: 'not_found', status: 404),
          a_hash_including(name: 'unprocessable_entity', status: 422),
        )
      end
    end
  end
end
