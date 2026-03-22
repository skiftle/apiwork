# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::BuilderMapper do
  describe '.map' do
    context 'with empty types' do
      it 'returns empty string' do
        export = stub_export
        surface = build_surface(types: {})

        result = described_class.map(export, surface)

        expect(result).to eq('')
      end
    end

    context 'with object type without defaults' do
      it 'generates passthrough builder' do
        export = stub_export
        surface = build_surface(
          types: {
            invoice: build_type(
              shape: {
                amount: { type: :decimal },
                number: { type: :string },
              },
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include('export function buildInvoice(fields: Invoice): Invoice {')
        expect(result).to include('return fields;')
      end
    end

    context 'with all fields defaulted' do
      it 'uses Partial with optional parameter' do
        export = stub_export
        surface = build_surface(
          types: {
            invoice: build_type(
              shape: {
                notes: { nullable: true, type: :string },
                sent: { default: false, type: :boolean },
              },
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include('fields?: Partial<Invoice>')
        expect(result).to include('notes: null,')
        expect(result).to include('sent: false,')
      end
    end

    context 'with mix of required and defaulted fields' do
      it 'uses Pick for required and Partial for defaults' do
        export = stub_export
        surface = build_surface(
          types: {
            invoice: build_type(
              shape: {
                number: { type: :string },
                sent: { default: false, type: :boolean },
              },
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include("Pick<Invoice, 'number'> & Partial<Invoice>")
        expect(result).to include('sent: false,')
        expect(result).to include('...fields,')
      end
    end

    context 'with nullable fields' do
      it 'prefills nullable fields with null' do
        export = stub_export
        surface = build_surface(
          types: {
            invoice: build_type(
              shape: {
                notes: { nullable: true, type: :string },
                number: { type: :string },
              },
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include("Pick<Invoice, 'number'> & Partial<Invoice>")
        expect(result).to include('notes: null,')
      end
    end

    context 'with optional fields' do
      it 'treats optional fields as required' do
        export = stub_export
        surface = build_surface(
          types: {
            invoice: build_type(
              shape: {
                notes: { optional: true, type: :string },
                number: { type: :string },
              },
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include('export function buildInvoice(fields: Invoice): Invoice {')
        expect(result).to include('return fields;')
        expect(result).not_to include('undefined')
      end
    end

    context 'with discriminated union' do
      it 'generates passthrough builder and per-variant builders' do
        export = stub_export
        surface = build_surface(
          types: {
            customer: build_union_type(
              discriminator: :kind,
              variants: [
                { shape: { name: { type: :string } }, tag: 'organization', type: :object },
                { shape: { name: { type: :string } }, tag: 'individual', type: :object },
              ],
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include('export function buildCustomer(fields: Customer): Customer {')
        expect(result).to include('return fields;')
        expect(result).to include('export function buildCustomerOrganization(')
        expect(result).to include("kind: 'organization',")
        expect(result).to include('export function buildCustomerIndividual(')
        expect(result).to include("kind: 'individual',")
      end
    end

    context 'with union without discriminator' do
      it 'generates only passthrough builder' do
        export = stub_export
        surface = build_surface(
          types: {
            payment_method: build_union_type(
              variants: [
                { type: :string },
                { type: :integer },
              ],
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include('export function buildPaymentMethod(fields: PaymentMethod): PaymentMethod {')
        expect(result).not_to include('buildPaymentMethodString')
      end
    end

    context 'with camel key_format' do
      it 'transforms field names in defaults and type params' do
        export = stub_export
        export.define_singleton_method(:transform_key) { |key| key.to_s.camelize(:lower) }
        surface = build_surface(
          types: {
            invoice: build_type(
              shape: {
                due_on: { type: :date },
                is_sent: { default: false, type: :boolean },
              },
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include("Pick<Invoice, 'dueOn'> & Partial<Invoice>")
        expect(result).to include('isSent: false,')
      end
    end

    context 'with string default value' do
      it 'serializes as quoted string' do
        export = stub_export
        surface = build_surface(
          types: {
            invoice: build_type(
              shape: {
                number: { type: :string },
                status: { default: 'draft', type: :string },
              },
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include("status: 'draft',")
      end
    end

    context 'with string default containing single quotes' do
      it 'escapes single quotes' do
        export = stub_export
        surface = build_surface(
          types: {
            invoice: build_type(
              shape: {
                note: { default: "it's pending", type: :string },
                number: { type: :string },
              },
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include("note: 'it\\'s pending',")
      end
    end

    context 'with discriminated union variant with defaulted fields' do
      it 'omits discriminator from variant fields type' do
        export = stub_export
        surface = build_surface(
          types: {
            customer: build_union_type(
              discriminator: :kind,
              variants: [
                {
                  shape: {
                    active: { default: true, type: :boolean },
                    name: { type: :string },
                  },
                  tag: 'organization',
                  type: :object,
                },
              ],
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include("Omit<Extract<Customer, { kind: 'organization' }>, 'kind'>")
        expect(result).to include("Pick<Omit<Extract<Customer, { kind: 'organization' }>, 'kind'>, 'name'>")
        expect(result).to include('active: true,')
        expect(result).not_to include("Partial<Extract<Customer, { kind: 'organization' }>>")
      end
    end

    context 'with discriminated union with reference variants' do
      it 'uses reference type name for builder function' do
        export = stub_export
        surface = build_surface(
          types: {
            customer_payload: build_union_type(
              discriminator: :kind,
              variants: [
                { reference: :customer_organization_payload, tag: 'organization', type: :reference },
                { reference: :customer_individual_payload, tag: 'individual', type: :reference },
              ],
            ),
          },
        )

        result = described_class.map(export, surface)

        expect(result).to include('export function buildCustomerOrganizationPayload(')
        expect(result).to include('export function buildCustomerIndividualPayload(')
        expect(result).not_to include('buildCustomerPayloadOrganization')
        expect(result).not_to include('buildCustomerPayloadIndividual')
      end
    end

    context 'with discriminated union whose reference variants exist as types' do
      it 'skips variant builders to avoid duplicates' do
        export = stub_export
        surface = build_surface(
          types: {
            customer_individual_payload: build_type(
              shape: { name: { type: :string } },
            ),
            customer_organization_payload: build_type(
              shape: { name: { type: :string } },
            ),
            customer_payload: build_union_type(
              discriminator: :kind,
              variants: [
                { reference: :customer_organization_payload, tag: 'organization', type: :reference },
                { reference: :customer_individual_payload, tag: 'individual', type: :reference },
              ],
            ),
          },
        )

        result = described_class.map(export, surface)

        occurrences = result.scan('export function buildCustomerOrganizationPayload(').length

        expect(occurrences).to eq(1)
      end
    end
  end
end
