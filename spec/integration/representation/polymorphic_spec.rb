# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation polymorphic associations', type: :integration do
  let!(:customer) { PersonCustomer.create!(email: 'ANNA@EXAMPLE.COM', name: 'Anna Svensson') }
  let!(:invoice1) { Invoice.create!(customer: customer, number: 'INV-001', status: :draft) }
  let!(:tag1) { Tag.create!(name: 'Priority', slug: 'priority') }
  let!(:tag2) { Tag.create!(name: 'Urgent', slug: 'urgent') }
  let!(:tagging1) { Tagging.create!(tag: tag1, taggable: invoice1) }
  let!(:tagging2) { Tagging.create!(tag: tag2, taggable: invoice1) }

  context 'with include' do
    it 'serializes taggings with tag_id when included' do
      result = Api::V1::InvoiceRepresentation.serialize(invoice1, include: { taggings: true })

      expect(result[:taggings].length).to eq(2)
      tag_ids = result[:taggings].map { |tagging| tagging[:tag_id] }
      expect(tag_ids).to contain_exactly(tag1.id, tag2.id)
    end
  end

  context 'without include' do
    it 'serializes without taggings key' do
      result = Api::V1::InvoiceRepresentation.serialize(invoice1)

      expect(result).not_to have_key(:taggings)
    end
  end

  context 'with nested include' do
    it 'serializes taggings with nested tag data' do
      result = Api::V1::InvoiceRepresentation.serialize(invoice1, include: { taggings: { tag: true } })

      tagging = result[:taggings].find { |item| item[:tag_id] == tag1.id }
      expect(tagging[:tag][:name]).to eq('Priority')
      expect(tagging[:tag][:slug]).to eq('priority')
    end
  end
end
