# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Skip contract validation', type: :request do
  let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:service) { Service.create!(customer: customer, description: 'Monthly consulting', name: 'Consulting') }

  describe 'PATCH /api/v1/services/:id/deactivate' do
    it 'returns the service with unknown body field' do
      patch "/api/v1/services/#{service.id}/deactivate",
            as: :json,
            params: { unknown_field: 'value' }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['service']['name']).to eq('Consulting')
    end
  end

  describe 'PATCH /api/v1/services/:id/restrict' do
    it 'returns error for unknown body field' do
      patch "/api/v1/services/#{service.id}/restrict",
            as: :json,
            params: { unknown_field: 'value' }

      expect(response).to have_http_status(:bad_request)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'field_unknown' }
      expect(issue['code']).to eq('field_unknown')
    end
  end
end
