# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Expose error', type: :request do
  let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:service) { Service.create!(customer: customer, description: 'Monthly consulting', name: 'Consulting') }

  describe 'PATCH /api/v1/services/:id/restrict' do
    it 'returns forbidden for default expose_error' do
      patch "/api/v1/services/#{service.id}/restrict", as: :json, params: {}

      expect(response).to have_http_status(:forbidden)
      body = response.parsed_body
      expect(body['layer']).to eq('http')
      issue = body['issues'].first
      expect(issue['code']).to eq('forbidden')
      expect(issue['detail']).to eq('Forbidden')
      expect(issue['path']).to eq([])
      expect(issue['pointer']).to eq('')
      expect(issue['meta']).to eq({})
    end
  end

  describe 'PATCH /api/v1/services/:id/archive' do
    it 'returns forbidden for expose_error with custom options' do
      patch "/api/v1/services/#{service.id}/archive", as: :json, params: {}

      expect(response).to have_http_status(:forbidden)
      body = response.parsed_body
      expect(body['layer']).to eq('http')
      issue = body['issues'].first
      expect(issue['code']).to eq('forbidden')
      expect(issue['detail']).to eq('Service is archived')
      expect(issue['path']).to eq(%w[service])
      expect(issue['pointer']).to eq('/service')
      expect(issue['meta']).to eq({ 'reason' => 'archived' })
    end
  end

  describe 'PATCH /api/v1/services/:id/expire' do
    it 'returns not found for expose_error with attach_path' do
      patch "/api/v1/services/#{service.id}/expire", as: :json, params: {}

      expect(response).to have_http_status(:not_found)
      body = response.parsed_body
      expect(body['layer']).to eq('http')
      issue = body['issues'].first
      expect(issue['code']).to eq('not_found')
      expect(issue['detail']).to eq('Not Found')
      expect(issue['path']).to eq(['services', service.id.to_s, 'expire'])
      expect(issue['pointer']).to eq("/services/#{service.id}/expire")
      expect(issue['meta']).to eq({})
    end
  end
end
