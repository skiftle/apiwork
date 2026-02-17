# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Capability::Transformer::Response::Base do
  describe '#transform' do
    it 'raises NotImplementedError' do
      transformer = described_class.new(nil)

      expect { transformer.transform }.to raise_error(NotImplementedError)
    end
  end
end
