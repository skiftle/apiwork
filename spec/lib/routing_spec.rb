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

  describe '.reset!' do
    it 'clears API registry' do
      expect(Apiwork::API.all).not_to be_empty

      Apiwork.reset!

      expect(Apiwork::API.all).to be_empty
    end

    it 'clears ErrorCode registry and re-registers defaults' do
      initial_count = Apiwork::ErrorCode::Registry.all.size
      Apiwork::ErrorCode.register(:custom_test_error, status: 499)

      expect(Apiwork::ErrorCode::Registry.all.size).to eq(initial_count + 1)

      Apiwork.reset!

      expect(Apiwork::ErrorCode::Registry.all.size).to eq(initial_count)
      expect(Apiwork::ErrorCode.registered?(:custom_test_error)).to be false
    end
  end
end
