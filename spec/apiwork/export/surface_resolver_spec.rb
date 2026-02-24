# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::SurfaceResolver do
  def build_api(enums: {}, resources: {}, types: {})
    Apiwork::Introspection::API.new(
      {
        enums:,
        resources:,
        types:,
        error_codes: {},
      },
    )
  end

  def build_resource(actions: {}, resources: {})
    { actions:, resources:, identifier: 'invoices', parent_identifiers: [], path: 'invoices' }
  end

  def build_action(body: {}, query: {}, response_body: nil)
    {
      deprecated: false,
      description: nil,
      method: :get,
      operation_id: nil,
      path: '/invoices',
      raises: [],
      request: { body:, query: },
      response: { body: response_body, no_content: response_body.nil? },
      summary: nil,
      tags: [],
    }
  end

  def reference_param(name)
    {
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      reference: name,
      type: :reference,
    }
  end

  def string_param(enum: nil)
    {
      deprecated: false,
      description: nil,
      example: nil,
      format: nil,
      max: nil,
      min: nil,
      nullable: false,
      optional: false,
      type: :string,
    }.tap do |param|
      param[:enum] = enum if enum
    end
  end

  def object_type(extends: [], shape: {})
    {
      extends:,
      shape:,
      deprecated: false,
      description: nil,
      discriminator: nil,
      example: nil,
      type: :object,
      variants: [],
    }
  end

  def union_type(variants: [])
    {
      variants:,
      deprecated: false,
      description: nil,
      discriminator: nil,
      example: nil,
      extends: [],
      shape: {},
      type: :union,
    }
  end

  def object_param(shape: {})
    {
      shape:,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      partial: false,
      type: :object,
    }
  end

  def array_param(of: nil, shape: {})
    {
      of:,
      shape:,
      deprecated: false,
      description: nil,
      example: nil,
      max: nil,
      min: nil,
      nullable: false,
      optional: false,
      type: :array,
    }
  end

  def union_param(variants: [])
    {
      variants:,
      deprecated: false,
      description: nil,
      discriminator: nil,
      example: nil,
      nullable: false,
      optional: false,
      type: :union,
    }
  end

  describe '#enums' do
    it 'includes enums referenced in action query' do
      api = build_api(
        enums: { status: { values: %w[draft sent paid] } },
        resources: { invoices: build_resource(
          actions: {
            index: build_action(query: { status: string_param(enum: :status) }),
          },
        ) },
      )

      surface = described_class.resolve(api)

      expect(surface.enums.keys).to eq([:status])
    end

    it 'includes enums referenced in action body' do
      api = build_api(
        enums: { status: { values: %w[draft sent paid] } },
        resources: { invoices: build_resource(
          actions: {
            create: build_action(body: { status: string_param(enum: :status) }),
          },
        ) },
      )

      surface = described_class.resolve(api)

      expect(surface.enums.keys).to eq([:status])
    end

    it 'includes enums from nested resource actions' do
      api = build_api(
        enums: { status: { values: %w[draft sent paid] } },
        resources: { invoices: build_resource(
          actions: {},
          resources: { items: build_resource(
            actions: {
              index: build_action(query: { status: string_param(enum: :status) }),
            },
          ) },
        ) },
      )

      surface = described_class.resolve(api)

      expect(surface.enums.keys).to eq([:status])
    end

    it 'includes enums referenced in resolved types' do
      api = build_api(
        enums: { status: { values: %w[draft sent paid] } },
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: {
          invoice: object_type(shape: { status: string_param(enum: :status) }),
        },
      )

      surface = described_class.resolve(api)

      expect(surface.enums.keys).to eq([:status])
    end

    it 'includes enums referenced via type reference pointing to enum' do
      api = build_api(
        enums: { status: { values: %w[draft sent paid] } },
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: {
          invoice: object_type(shape: { status: reference_param(:status) }),
        },
      )

      surface = described_class.resolve(api)

      expect(surface.enums.keys).to eq([:status])
    end

    it 'includes enums from union type variants' do
      api = build_api(
        enums: { status: { values: %w[draft sent paid] } },
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:payment)),
          },
        ) },
        types: {
          payment: union_type(
            variants: [
              object_param(shape: { status: string_param(enum: :status) }),
            ],
          ),
        },
      )

      surface = described_class.resolve(api)

      expect(surface.enums.keys).to eq([:status])
    end

    it 'excludes unreferenced enums' do
      api = build_api(
        enums: { priority: { values: %w[low high] }, status: { values: %w[draft sent paid] } },
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: { invoice: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.enums).to be_empty
    end

    it 'returns empty when no resources' do
      api = build_api(
        enums: { status: { values: %w[draft sent paid] } },
      )

      surface = described_class.resolve(api)

      expect(surface.enums).to be_empty
    end
  end

  describe '#types' do
    it 'includes types referenced in response body' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: { invoice: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:invoice])
    end

    it 'includes types referenced in request body' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            create: build_action(body: { invoice: reference_param(:invoice) }),
          },
        ) },
        types: { invoice: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:invoice])
    end

    it 'includes types referenced in request query' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            index: build_action(query: { filter: reference_param(:invoice) }),
          },
        ) },
        types: { invoice: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:invoice])
    end

    it 'includes types from array element' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            index: build_action(response_body: array_param(of: reference_param(:item))),
          },
        ) },
        types: { item: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:item])
    end

    it 'includes types from nested object shape' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(
              response_body: object_param(
                shape: {
                  customer: reference_param(:customer),
                },
              ),
            ),
          },
        ) },
        types: { customer: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:customer])
    end

    it 'includes types from array shape' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            index: build_action(
              response_body: array_param(
                shape: { item: reference_param(:item) },
              ),
            ),
          },
        ) },
        types: { item: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:item])
    end

    it 'includes types from nested resource actions' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {},
          resources: { items: build_resource(
            actions: {
              show: build_action(response_body: reference_param(:item)),
            },
          ) },
        ) },
        types: { item: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:item])
    end

    it 'includes types from action union params' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            create: build_action(
              body: {
                target: union_param(
                  variants: [reference_param(:invoice),
                             reference_param(:receipt)],
                ),
              },
            ),
          },
        ) },
        types: { invoice: object_type, receipt: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to contain_exactly(:invoice, :receipt)
    end

    it 'includes transitively referenced types' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: {
          invoice: object_type(shape: { item: reference_param(:item) }),
          item: object_type,
        },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to contain_exactly(:invoice, :item)
    end

    it 'includes deeply nested transitive types' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: {
          adjustment: object_type,
          invoice: object_type(shape: { item: reference_param(:item) }),
          item: object_type(shape: { adjustment: reference_param(:adjustment) }),
        },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to contain_exactly(:invoice, :item, :adjustment)
    end

    it 'includes types from extends' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: {
          invoice: object_type(extends: [:receipt]),
          receipt: object_type,
        },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to contain_exactly(:invoice, :receipt)
    end

    it 'includes types referenced in type shape' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: {
          customer: object_type,
          invoice: object_type(shape: { customer: reference_param(:customer) }),
        },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to contain_exactly(:invoice, :customer)
    end

    it 'includes types from union variants' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:payment)),
          },
        ) },
        types: {
          invoice: object_type,
          payment: union_type(variants: [reference_param(:invoice), reference_param(:receipt)]),
          receipt: object_type,
        },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to contain_exactly(:payment, :invoice, :receipt)
    end

    it 'includes types from union fields in type shapes' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: {
          customer: object_type,
          invoice: object_type(
            shape: {
              payment: union_param(variants: [reference_param(:customer), reference_param(:service)]),
            },
          ),
          service: object_type,
        },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to contain_exactly(:invoice, :customer, :service)
    end

    it 'excludes unreferenced types' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: { invoice: object_type, receipt: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:invoice])
    end

    it 'excludes references to undefined types' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            show: build_action(response_body: reference_param(:invoice)),
          },
        ) },
        types: {
          invoice: object_type(shape: { customer: reference_param(:customer) }),
        },
      )

      surface = described_class.resolve(api)

      expect(surface.types.keys).to eq([:invoice])
    end

    it 'returns empty for no_content responses' do
      api = build_api(
        resources: { invoices: build_resource(
          actions: {
            destroy: build_action,
          },
        ) },
        types: { invoice: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types).to be_empty
    end

    it 'returns empty when no resources' do
      api = build_api(
        types: { invoice: object_type },
      )

      surface = described_class.resolve(api)

      expect(surface.types).to be_empty
    end
  end
end
