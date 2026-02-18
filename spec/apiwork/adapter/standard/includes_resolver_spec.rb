# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Standard::IncludesResolver do
  IncludesResolverMockAssociation = Struct.new(:include, :representation_class, keyword_init: true)

  def build_representation_class(associations: {}, name: 'InvoiceRepresentation')
    klass = Class.new do
      class << self
        attr_accessor :associations_hash, :class_name
      end

      def self.associations
        associations_hash
      end

      def self.name
        class_name
      end
    end

    klass.class_name = name
    klass.associations_hash = associations.transform_values do |config|
      IncludesResolverMockAssociation.new(
        include: config[:include] || :optional,
        representation_class: config[:representation_class],
      )
    end

    klass
  end

  describe '.resolve' do
    context 'with empty params' do
      let(:representation_class) { build_representation_class }

      it 'returns empty array' do
        result = described_class.resolve(representation_class, {})

        expect(result).to eq([])
      end
    end

    context 'with include_always: true' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :always, representation_class: customer_representation },
          },
        )
      end

      it 'includes always-included associations' do
        result = described_class.resolve(representation_class, {}, include_always: true)

        expect(result).to eq(:customer)
      end
    end
  end

  describe '#always_included' do
    let(:resolver) { described_class.new(representation_class) }

    context 'when no associations have include: :always' do
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :optional },
          },
        )
      end

      it 'returns empty hash' do
        result = resolver.always_included

        expect(result).to eq({})
      end
    end

    context 'when associations have include: :always' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :always, representation_class: customer_representation },
          },
        )
      end

      it 'returns hash with association name' do
        result = resolver.always_included

        expect(result).to eq({ customer: {} })
      end
    end

    context 'when nested associations have include: :always' do
      let(:address_representation) { build_representation_class(name: 'AddressRepresentation') }
      let(:customer_representation) do
        build_representation_class(
          associations: {
            address: { include: :always, representation_class: address_representation },
          },
          name: 'CustomerRepresentation',
        )
      end
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :always, representation_class: customer_representation },
          },
        )
      end

      it 'includes nested always-included associations' do
        result = resolver.always_included

        expect(result).to eq({ customer: { address: {} } })
      end
    end
  end

  describe '#format' do
    let(:resolver) { described_class.new(representation_class) }

    let(:representation_class) { build_representation_class }

    context 'when hash is blank' do
      it 'returns empty array' do
        result = resolver.format({})

        expect(result).to eq([])
      end
    end

    context 'when hash has single key with empty value' do
      it 'returns key as symbol' do
        result = resolver.format({ customer: {} })

        expect(result).to eq(:customer)
      end
    end

    context 'when hash has single key with nested value' do
      it 'returns hash with formatted nested value' do
        result = resolver.format({ customer: { address: {} } })

        expect(result).to eq({ customer: :address })
      end
    end

    context 'when hash has multiple keys' do
      it 'returns array of formatted items' do
        result = resolver.format({ customer: {}, payment: {} })

        expect(result).to contain_exactly(:customer, :payment)
      end
    end

    context 'when hash has deeply nested values' do
      it 'recursively formats nested values' do
        result = resolver.format({ customer: { address: { city: {} } } })

        expect(result).to eq({ customer: { address: :city } })
      end
    end

    context 'when hash has multiple keys with nested values' do
      it 'returns array with formatted items' do
        result = resolver.format(
          {
            customer: { address: {} },
            payment: { method: {} },
          },
        )

        expect(result).to contain_exactly(
          { customer: :address },
          { payment: :method },
        )
      end
    end
  end

  describe '#from_params' do
    let(:resolver) { described_class.new(representation_class) }

    let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
    let(:representation_class) do
      build_representation_class(
        associations: {
          customer: { include: :optional, representation_class: customer_representation },
        },
      )
    end

    context 'when params is empty' do
      it 'returns empty hash' do
        result = resolver.from_params({})

        expect(result).to eq({})
      end
    end

    context 'when params contains association' do
      it 'returns hash with association' do
        result = resolver.from_params({ customer: {} })

        expect(result).to eq({ customer: {} })
      end
    end
  end

  describe '#merge' do
    let(:resolver) { described_class.new(representation_class) }

    let(:representation_class) { build_representation_class }

    context 'when override is blank' do
      it 'returns base unchanged' do
        result = resolver.merge({ customer: {} }, {})

        expect(result).to eq({ customer: {} })
      end
    end

    context 'when override has values' do
      it 'deep merges override into base' do
        result = resolver.merge({ customer: {} }, { payment: {} })

        expect(result).to eq({ customer: {}, payment: {} })
      end
    end

    context 'when override has nested values' do
      it 'deep merges nested values' do
        result = resolver.merge(
          { customer: { address: {} } },
          { customer: { billing: {} } },
        )

        expect(result).to eq({ customer: { address: {}, billing: {} } })
      end
    end

    context 'when override has string keys' do
      it 'symbolizes keys' do
        result = resolver.merge({ customer: {} }, { 'payment' => {} })

        expect(result).to eq({ customer: {}, payment: {} })
      end
    end
  end

  describe '#resolve' do
    let(:resolver) { described_class.new(representation_class) }

    context 'when params is empty' do
      let(:representation_class) { build_representation_class }

      context 'without include_always' do
        it 'returns empty array' do
          result = resolver.resolve({})

          expect(result).to eq([])
        end
      end

      context 'with include_always: true' do
        let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
        let(:representation_class) do
          build_representation_class(
            associations: {
              customer: { include: :always, representation_class: customer_representation },
            },
          )
        end

        it 'returns always-included associations' do
          result = resolver.resolve({}, include_always: true)

          expect(result).to eq(:customer)
        end
      end
    end

    context 'when params contains association keys' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :optional, representation_class: customer_representation },
          },
        )
      end

      it 'extracts matching associations' do
        result = resolver.resolve({ customer: {} })

        expect(result).to eq(:customer)
      end
    end

    context 'when params contains nested associations' do
      let(:address_representation) { build_representation_class(name: 'AddressRepresentation') }
      let(:customer_representation) do
        build_representation_class(
          associations: {
            address: { include: :optional, representation_class: address_representation },
          },
          name: 'CustomerRepresentation',
        )
      end
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :optional, representation_class: customer_representation },
          },
        )
      end

      it 'extracts nested associations' do
        result = resolver.resolve({ customer: { address: {} } })

        expect(result).to eq({ customer: :address })
      end
    end

    context 'when params contains multiple associations at same level' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:payment_representation) { build_representation_class(name: 'PaymentRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :optional, representation_class: customer_representation },
            payment: { include: :optional, representation_class: payment_representation },
          },
        )
      end

      it 'extracts all associations' do
        result = resolver.resolve(
          {
            customer: { name: { eq: 'Acme' } },
            payment: { amount: { gt: 100 } },
          },
        )

        expect(result).to contain_exactly(:customer, :payment)
      end
    end

    context 'when params contains OR logical operator' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:payment_representation) { build_representation_class(name: 'PaymentRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :optional, representation_class: customer_representation },
            payment: { include: :optional, representation_class: payment_representation },
          },
        )
      end

      it 'extracts associations from all branches' do
        result = resolver.resolve(
          {
            OR: [
              { customer: { name: { eq: 'Acme' } } },
              { payment: { amount: { gt: 100 } } },
            ],
          },
        )

        expect(result).to contain_exactly(:customer, :payment)
      end
    end

    context 'when params contains AND logical operator' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:payment_representation) { build_representation_class(name: 'PaymentRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :optional, representation_class: customer_representation },
            payment: { include: :optional, representation_class: payment_representation },
          },
        )
      end

      it 'extracts associations from all branches' do
        result = resolver.resolve(
          {
            AND: [
              { customer: { name: { eq: 'Acme' } } },
              { payment: { amount: { gt: 100 } } },
            ],
          },
        )

        expect(result).to contain_exactly(:customer, :payment)
      end
    end

    context 'when params contains NOT logical operator' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :optional, representation_class: customer_representation },
          },
        )
      end

      it 'extracts associations from negated branch' do
        result = resolver.resolve({ NOT: { customer: { name: { eq: 'Acme' } } } })

        expect(result).to eq(:customer)
      end
    end

    context 'when params contains nested OR with same association' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :optional, representation_class: customer_representation },
          },
        )
      end

      it 'extracts association once' do
        result = resolver.resolve(
          {
            OR: [
              { customer: { name: { eq: 'Acme' } } },
              { customer: { name: { eq: 'Beta' } } },
            ],
          },
        )

        expect(result).to eq(:customer)
      end
    end

    context 'when params contains non-association keys' do
      let(:representation_class) { build_representation_class }

      it 'ignores non-association keys' do
        result = resolver.resolve({ status: { eq: 'active' } })

        expect(result).to eq([])
      end
    end

    context 'with circular reference' do
      let(:representation_class) do
        klass = build_representation_class(name: 'InvoiceRepresentation')
        klass.associations_hash = {
          parent: IncludesResolverMockAssociation.new(include: :always, representation_class: klass),
        }
        klass
      end

      it 'prevents infinite recursion' do
        result = resolver.resolve({}, include_always: true)

        expect(result).to eq(:parent)
      end
    end

    context 'when combining always_included and params' do
      let(:customer_representation) { build_representation_class(name: 'CustomerRepresentation') }
      let(:payment_representation) { build_representation_class(name: 'PaymentRepresentation') }
      let(:representation_class) do
        build_representation_class(
          associations: {
            customer: { include: :always, representation_class: customer_representation },
            payment: { include: :optional, representation_class: payment_representation },
          },
        )
      end

      it 'merges always_included with params' do
        result = resolver.resolve({ payment: {} }, include_always: true)

        expect(result).to contain_exactly(:customer, :payment)
      end
    end
  end
end
