# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation writable context', type: :integration do
  describe 'writable: :create' do
    it 'reports writable for create context' do
      attribute = Api::V1::AddressRepresentation.attributes[:street]

      expect(attribute.writable?).to be(true)
      expect(attribute.writable_for?(:create)).to be(true)
      expect(attribute.writable_for?(:update)).to be(false)
    end
  end

  describe 'writable: :update' do
    it 'reports writable for update context' do
      attribute = Api::V1::AddressRepresentation.attributes[:country]

      expect(attribute.writable?).to be(true)
      expect(attribute.writable_for?(:create)).to be(false)
      expect(attribute.writable_for?(:update)).to be(true)
    end
  end

  describe 'writable: true' do
    it 'reports writable for both contexts' do
      attribute = Api::V1::AddressRepresentation.attributes[:city]

      expect(attribute.writable?).to be(true)
      expect(attribute.writable_for?(:create)).to be(true)
      expect(attribute.writable_for?(:update)).to be(true)
    end
  end

  describe 'writable: false' do
    it 'reports not writable for any context' do
      attribute = Api::V1::AddressRepresentation.attributes[:id]

      expect(attribute.writable?).to be(false)
      expect(attribute.writable_for?(:create)).to be(false)
      expect(attribute.writable_for?(:update)).to be(false)
    end
  end

  describe 'attribute metadata' do
    it 'exposes description on attribute' do
      attribute = Api::V1::AddressRepresentation.attributes[:street]

      expect(attribute.description).to eq('Street address line')
    end

    it 'exposes example on attribute' do
      attribute = Api::V1::AddressRepresentation.attributes[:country]

      expect(attribute.example).to eq('SE')
    end

    it 'exposes deprecated on attribute' do
      attribute = Api::V1::AddressRepresentation.attributes[:country]

      expect(attribute.deprecated?).to be(true)
    end

    it 'exposes non-deprecated on attribute' do
      attribute = Api::V1::AddressRepresentation.attributes[:city]

      expect(attribute.deprecated?).to be(false)
    end

    it 'exposes format on attribute' do
      attribute = Api::V1::ProfileRepresentation.attributes[:external_id]

      expect(attribute.format).to eq(:uuid)
    end
  end

  describe 'representation metadata' do
    it 'exposes description on representation' do
      expect(Api::V1::ProfileRepresentation.description).to eq('Billing profile with personal settings')
    end

    it 'exposes deprecated on representation' do
      expect(Api::V1::ProfileRepresentation.deprecated?).to be(true)
    end

    it 'exposes example on representation' do
      expected = { email: 'admin@billing.test', name: 'Admin', timezone: 'Europe/Stockholm' }

      expect(Api::V1::ProfileRepresentation.example).to eq(expected)
    end

    it 'reports non-deprecated for standard representation' do
      expect(Api::V1::InvoiceRepresentation.deprecated?).to be(false)
    end
  end

  describe 'notes attribute description on invoice' do
    it 'exposes description from with_options block' do
      attribute = Api::V1::InvoiceRepresentation.attributes[:notes]

      expect(attribute.description).to eq('Payment terms and notes')
    end
  end
end
