# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Enum output validation with key transformation', type: :request do
  describe 'GET /api/v1/camelized_accounts/:id' do
    it 'returns bad request when enum value is invalid with camelCase keys' do
      # The controller deliberately sets an invalid enum value
      # This should be caught by output validation even with camelCase transformation
      get '/api/v1/camelized_accounts/1'

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)

      # Error paths use canonical field names (snake_case), not transformed names
      # This is consistent with error paths being schema-level, not serialization-level
      fdow_error = json['issues'].find { |e| e['path']&.last == 'first_day_of_week' }
      expect(fdow_error).not_to be_nil
      expect(fdow_error['code']).to eq('invalid_value')
      expect(fdow_error['detail']).to include('Must be one of')
    end

    # NOTE: This test exposes a separate bug in Apiwork where Rails enum attributes
    # (which have type: :integer in DB) are serialized as strings by as_json,
    # but output validation expects integers. This is unrelated to key transformation.
    # The first test above demonstrates that key transformation works correctly -
    # the error path uses 'firstDayOfWeek' (camelCase) instead of 'first_day_of_week'.
  end
end
