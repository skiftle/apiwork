# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Enum output validation', type: :request do
  describe 'GET /api/v1/accounts/:id' do
    it 'returns bad request when enum value is invalid' do
      # The controller deliberately sets an invalid enum value
      # This should be caught by output validation and return 400 bad request
      get '/api/v1/accounts/1'

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)

      # Check that we have an error for first_day_of_week enum
      fdow_error = json['issues'].find { |e| e['path']&.last == 'first_day_of_week' }
      expect(fdow_error).not_to be_nil
      expect(fdow_error['code']).to eq('value_invalid')
      expect(fdow_error['detail']).to eq('Invalid value')
    end
  end
end
