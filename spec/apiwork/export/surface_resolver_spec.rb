# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::SurfaceResolver do
  def build_introspection(enums: {}, resources:, types: {})
    dump = {
      enums:,
      resources:,
      types:,
      error_codes: {},
      info: nil,
      path: '/api/test',
    }
    Apiwork::Introspection::API.new(dump)
  end

  def build_resource(actions:, resources: {})
    {
      actions:,
      resources:,
      identifier: 'invoices',
      parent_identifiers: [],
      path: 'invoices',
    }
  end

  def build_action(request: { body: {}, query: {} }, response: { body: nil, no_content: false })
    {
      request:,
      response:,
      deprecated: false,
      description: nil,
      method: :get,
      operation_id: nil,
      path: '/invoices',
      raises: [],
      summary: nil,
      tags: [],
    }
  end

  def build_reference_param(type_name)
    { nullable: false, optional: false, reference: type_name, type: :reference }
  end

  def build_object_type(extends: [], shape: {})
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

  def build_enum(values:)
    { values:, deprecated: false, description: nil, example: nil }
  end

  describe '#types' do
    it 'includes types referenced by response body' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {
              show: build_action(
                response: {
                  body: build_reference_param(:address),
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          address: build_object_type(shape: { city: { type: :string } }),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:address)
    end

    it 'excludes unreferenced types' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {
              show: build_action(
                response: {
                  body: build_reference_param(:address),
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          address: build_object_type(shape: { city: { type: :string } }),
          orphan: build_object_type(shape: { unused: { type: :string } }),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:address)
      expect(resolver.types.keys).not_to include(:orphan)
    end

    it 'includes transitively referenced types' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {
              show: build_action(
                response: {
                  body: build_reference_param(:address),
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          address: build_object_type(
            shape: {
              city: { type: :string },
              country: { reference: :country, type: :reference },
            },
          ),
          country: build_object_type(shape: { name: { type: :string } }),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:address)
      expect(resolver.types.keys).to include(:country)
    end

    it 'includes types from extends' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {
              show: build_action(
                response: {
                  body: build_reference_param(:child),
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          base_a: build_object_type(shape: { name: { type: :string } }),
          base_b: build_object_type(shape: { email: { type: :string } }),
          child: build_object_type(extends: [:base_a, :base_b], shape: {}),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:child)
      expect(resolver.types.keys).to include(:base_a)
      expect(resolver.types.keys).to include(:base_b)
    end

    it 'includes types from request body' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {
              create: build_action(
                request: {
                  body: { invoice: build_reference_param(:invoice_params) },
                  query: {},
                },
              ),
            },
          ),
        },
        types: {
          invoice_params: build_object_type(shape: { number: { type: :string } }),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:invoice_params)
    end

    it 'includes types from query parameters' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {
              index: build_action(
                request: {
                  body: {},
                  query: { filter: build_reference_param(:filter_options) },
                },
              ),
            },
          ),
        },
        types: {
          filter_options: build_object_type(shape: { status: { type: :string } }),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:filter_options)
    end

    it 'includes types from nested resources' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {},
            resources: {
              payments: {
                actions: {
                  show: build_action(
                    response: {
                      body: build_reference_param(:payment),
                      no_content: false,
                    },
                  ),
                },
                identifier: 'payments',
                parent_identifiers: ['invoices'],
                path: ':invoice_id/payments',
                resources: {},
              },
            },
          ),
        },
        types: {
          payment: build_object_type(shape: { amount: { type: :string } }),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:payment)
    end

    it 'includes types from inline objects within arrays' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {
              index: build_action(
                response: {
                  body: {
                    of: build_reference_param(:invoice),
                    shape: {},
                    type: :array,
                  },
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          invoice: build_object_type(shape: { number: { type: :string } }),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:invoice)
    end

    it 'includes types from union variants' do
      introspection = build_introspection(
        resources: {
          invoices: build_resource(
            actions: {
              show: build_action(
                response: {
                  body: {
                    type: :union,
                    variants: [
                      build_reference_param(:card_payment),
                      build_reference_param(:bank_payment),
                    ],
                  },
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          bank_payment: build_object_type(shape: { account: { type: :string } }),
          card_payment: build_object_type(shape: { last_four: { type: :string } }),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.types.keys).to include(:card_payment)
      expect(resolver.types.keys).to include(:bank_payment)
    end
  end

  describe '#enums' do
    it 'includes enums used in reachable types' do
      introspection = build_introspection(
        enums: {
          invoice_status: build_enum(values: %w[draft sent paid]),
        },
        resources: {
          invoices: build_resource(
            actions: {
              show: build_action(
                response: {
                  body: build_reference_param(:invoice),
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          invoice: build_object_type(
            shape: {
              status: { enum: :invoice_status, type: :string },
            },
          ),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.enums.keys).to include(:invoice_status)
    end

    it 'includes enums used directly in action params' do
      introspection = build_introspection(
        enums: {
          sort_direction: build_enum(values: %w[asc desc]),
        },
        resources: {
          invoices: build_resource(
            actions: {
              index: build_action(
                request: {
                  body: {},
                  query: {
                    sort: { enum: :sort_direction, optional: true, type: :string },
                  },
                },
              ),
            },
          ),
        },
        types: {},
      )

      resolver = described_class.new(introspection)

      expect(resolver.enums.keys).to include(:sort_direction)
    end

    it 'excludes unused enums' do
      introspection = build_introspection(
        enums: {
          invoice_status: build_enum(values: %w[draft sent paid]),
          orphan_enum: build_enum(values: %w[unused]),
        },
        resources: {
          invoices: build_resource(
            actions: {
              show: build_action(
                response: {
                  body: build_reference_param(:invoice),
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          invoice: build_object_type(
            shape: {
              status: { enum: :invoice_status, type: :string },
            },
          ),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.enums.keys).to include(:invoice_status)
      expect(resolver.enums.keys).not_to include(:orphan_enum)
    end

    it 'includes enums from transitively referenced types' do
      introspection = build_introspection(
        enums: {
          customer_status: build_enum(values: %w[active inactive]),
        },
        resources: {
          invoices: build_resource(
            actions: {
              show: build_action(
                response: {
                  body: build_reference_param(:invoice),
                  no_content: false,
                },
              ),
            },
          ),
        },
        types: {
          customer: build_object_type(
            shape: {
              status: { enum: :customer_status, type: :string },
            },
          ),
          invoice: build_object_type(
            shape: {
              customer: { reference: :customer, type: :reference },
            },
          ),
        },
      )

      resolver = described_class.new(introspection)

      expect(resolver.enums.keys).to include(:customer_status)
    end
  end
end
