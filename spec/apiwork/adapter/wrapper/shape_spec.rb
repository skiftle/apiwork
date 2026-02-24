# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Wrapper::Shape do
  describe '#initialize' do
    it 'creates with required attributes' do
      target = Object.new
      root_key = :invoice
      metadata_type_names = [:pagination]

      shape = described_class.new(target, root_key, metadata_type_names, data_type: :invoice_data)

      expect(shape.root_key).to eq(:invoice)
      expect(shape.metadata_type_names).to eq([:pagination])
      expect(shape.data_type).to eq(:invoice_data)
    end
  end
end
