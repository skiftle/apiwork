# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Error Response' do
  describe 'expose_error' do
    context 'with registered error code' do
      it 'returns correct HTTP status for not_found' do
        get '/api/v1/posts/999999'

        expect(response).to have_http_status(:not_found)
      end

      it 'returns Issue format' do
        get '/api/v1/posts/999999'

        json = JSON.parse(response.body)
        expect(json).to have_key('issues')
        expect(json['issues']).to be_an(Array)
        expect(json['issues'].first).to have_key('code')
        expect(json['issues'].first).to have_key('detail')
        expect(json['issues'].first).to have_key('path')
        expect(json['issues'].first).to have_key('pointer')
        expect(json['issues'].first).to have_key('meta')
      end

      it 'uses correct error code' do
        get '/api/v1/posts/999999'

        json = JSON.parse(response.body)
        expect(json['issues'].first['code']).to eq('not_found')
      end

      it 'uses i18n for detail' do
        get '/api/v1/posts/999999'

        json = JSON.parse(response.body)
        expect(json['issues'].first['detail']).to eq('Not Found')
      end
    end
  end

  describe 'Issue structure consistency' do
    it 'error response has same structure as validation errors' do
      get '/api/v1/posts/999999'
      error_response = JSON.parse(response.body)

      post '/api/v1/posts', params: { post: { title: nil } }, as: :json
      validation_response = JSON.parse(response.body)

      error_keys = error_response['issues'].first.keys.sort
      validation_keys = validation_response['issues'].first.keys.sort

      expect(error_keys).to eq(validation_keys)
    end
  end
end
