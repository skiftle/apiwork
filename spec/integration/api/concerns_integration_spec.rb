# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Concerns', type: :integration do
  it 'applies member actions from concern' do
    api = Apiwork::API.define '/api/concerns_test' do
      concern :auditable do
        member do
          get :audit_log
        end
      end

      resources :posts, concerns: [:auditable]
    end

    resource = api.root_resource.find_resource(:posts)
    expect(resource.member_actions).to have_key(:audit_log)
    expect(resource.member_actions[:audit_log].method).to eq(:get)
  end

  it 'applies collection actions from concern' do
    api = Apiwork::API.define '/api/concerns_test2' do
      concern :searchable do
        collection do
          get :search
        end
      end

      resources :posts, concerns: [:searchable]
    end

    resource = api.root_resource.find_resource(:posts)
    expect(resource.collection_actions).to have_key(:search)
    expect(resource.collection_actions[:search].method).to eq(:get)
  end

  it 'applies multiple concerns' do
    api = Apiwork::API.define '/api/concerns_test3' do
      concern :auditable do
        member do
          get :audit_log
        end
      end

      concern :searchable do
        collection do
          get :search
        end
      end

      resources :posts, concerns: %i[auditable searchable]
    end

    resource = api.root_resource.find_resource(:posts)
    expect(resource.member_actions).to have_key(:audit_log)
    expect(resource.collection_actions).to have_key(:search)
  end

  it 'raises error for unknown concern' do
    expect do
      Apiwork::API.define '/api/concerns_error' do
        resources :posts, concerns: [:unknown]
      end
    end.to raise_error(Apiwork::ConfigurationError, /No concern named :unknown/)
  end
end
