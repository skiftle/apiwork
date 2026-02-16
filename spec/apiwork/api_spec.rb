# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API do
  describe '.define' do
    it 'defines a new API' do
      api_class = described_class.define('/unit/api-define') {}

      expect(api_class).to be < Apiwork::API::Base
      expect(api_class.base_path).to eq('/unit/api-define')
    end
  end

  describe '.find' do
    it 'returns the API' do
      described_class.define('/unit/api-find') {}

      expect(described_class.find('/unit/api-find')).to be < Apiwork::API::Base
    end

    it 'returns nil when not found' do
      expect(described_class.find('/nonexistent')).to be_nil
    end
  end

  describe '.find!' do
    it 'returns the API' do
      described_class.define('/unit/api-find-bang') {}

      expect(described_class.find!('/unit/api-find-bang')).to be < Apiwork::API::Base
    end

    it 'raises KeyError when not found' do
      expect do
        described_class.find!('/nonexistent')
      end.to raise_error(KeyError, /nonexistent/)
    end
  end

  describe '.introspect' do
    it 'returns the introspection' do
      described_class.define('/unit/api-introspect') do
        resources :invoices
      end

      result = described_class.introspect('/unit/api-introspect')

      expect(result).to be_a(Apiwork::Introspection::API)
    end
  end
end
