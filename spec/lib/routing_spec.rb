# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Apiwork Rack Application' do
  before do
    load File.expand_path('../dummy/config/apis/v1.rb', __dir__)
  end

  describe '.call' do
    it 'responds to call with rack-compatible interface' do
      expect(Apiwork).to respond_to(:call)
    end

    it 'returns a rack-compatible response for valid route' do
      env = Rack::MockRequest.env_for('/api/v1/posts', method: :get)
      status, headers, body = Apiwork.call(env)

      expect(status).to eq(200)
      expect(headers).to include('content-type')
      expect(body).to respond_to(:each)
    end

    it 'returns 404 for unknown routes' do
      env = Rack::MockRequest.env_for('/api/v1/unknown_resource', method: :get)
      status, _headers, _body = Apiwork.call(env)

      expect(status).to eq(404)
    end

    it 'routes HEAD requests' do
      env = Rack::MockRequest.env_for('/api/v1/posts', method: :head)
      status, _headers, _body = Apiwork.call(env)

      expect(status).to eq(200)
    end
  end
end
