# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation polymorphic associations', type: :integration do
  let!(:customer) { PersonCustomer.create!(email: 'BILLING@ACME.COM', name: 'Acme Corp') }
  let!(:invoice) { Invoice.create!(customer: customer, number: 'INV-001') }
  let!(:tag1) { Tag.create!(name: 'Priority', slug: 'priority') }
  let!(:tag2) { Tag.create!(name: 'Urgent', slug: 'urgent') }

  describe 'serialize with polymorphic has_many' do
    let!(:tagging1) { invoice.taggings.create!(tag: tag1) }
    let!(:tagging2) { invoice.taggings.create!(tag: tag2) }

    it 'includes taggings when requested' do
      result = Api::V1::InvoiceRepresentation.serialize(invoice, include: { taggings: true })

      expect(result[:taggings].length).to eq(2)
      tag_ids = result[:taggings].map { |t| t[:tag_id] }
      expect(tag_ids).to contain_exactly(tag1.id, tag2.id)
    end

    it 'excludes taggings by default' do
      result = Api::V1::InvoiceRepresentation.serialize(invoice)

      expect(result).not_to have_key(:taggings)
    end
  end
end
