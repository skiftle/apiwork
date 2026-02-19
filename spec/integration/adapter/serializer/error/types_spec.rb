# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Error serializer types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }
  let(:enums) { introspection.enums }

  describe 'error object' do
    it 'has issues and layer' do
      error_type = types[:error]

      expect(error_type.type).to eq(:object)
      expect(error_type.shape.keys).to contain_exactly(:issues, :layer)
    end

    it 'has issues as array of issue references' do
      param = types[:error].shape[:issues]

      expect(param.type).to eq(:array)
      expect(param.of.type).to eq(:reference)
    end

    it 'has layer as reference to layer enum' do
      param = types[:error].shape[:layer]

      expect(param.type).to eq(:reference)
      expect(param.reference).to eq(:layer)
    end
  end

  describe 'issue object' do
    it 'has expected fields' do
      expect(types[:issue].shape.keys).to contain_exactly(:code, :detail, :meta, :path, :pointer)
    end
  end

  describe 'layer enum' do
    it 'has values' do
      expect(enums[:layer].values).to eq(%w[http contract domain])
    end
  end

  describe 'error response body' do
    let(:body) { types[:error_response_body] }

    it 'has type object' do
      expect(body.type).to eq(:object)
    end

    it 'extends error type' do
      expect(body.extends?).to be(true)
      expect(body.extends).to include(:error)
    end
  end
end
