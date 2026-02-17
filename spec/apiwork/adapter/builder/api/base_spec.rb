# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Builder::API::Base do
  describe '#build' do
    it 'raises NotImplementedError' do
      api_class = Class.new(Apiwork::API::Base)
      builder = described_class.new(api_class)

      expect { builder.build }.to raise_error(NotImplementedError)
    end
  end
end
