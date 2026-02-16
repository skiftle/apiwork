# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Inheritance do
  describe '#initialize' do
    it 'creates with required attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      inheritance = described_class.new(representation_class)

      expect(inheritance.base_class).to eq(representation_class)
      expect(inheritance.subclasses).to eq([])
    end
  end
end
