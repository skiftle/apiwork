# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API concerns', type: :request do
  it 'applies member actions from concern' do
    Apiwork::API.define '/api/concerns_member' do
      concern :auditable do
        member do
          get :audit_log
        end
      end

      resources :invoices, concerns: [:auditable]
    end

    api = Apiwork::API.find!('/api/concerns_member')
    resource = api.root_resource.find_resource(:invoices)
    expect(resource.member_actions).to have_key(:audit_log)
    expect(resource.member_actions[:audit_log].method).to eq(:get)
  ensure
    Apiwork::API::Registry.unregister('/api/concerns_member')
  end

  it 'applies collection actions from concern' do
    Apiwork::API.define '/api/concerns_collection' do
      concern :searchable do
        collection do
          get :search
        end
      end

      resources :invoices, concerns: [:searchable]
    end

    api = Apiwork::API.find!('/api/concerns_collection')
    resource = api.root_resource.find_resource(:invoices)
    expect(resource.collection_actions).to have_key(:search)
    expect(resource.collection_actions[:search].method).to eq(:get)
  ensure
    Apiwork::API::Registry.unregister('/api/concerns_collection')
  end

  it 'applies multiple concerns' do
    Apiwork::API.define '/api/concerns_multiple' do
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

      resources :invoices, concerns: %i[auditable searchable]
    end

    api = Apiwork::API.find!('/api/concerns_multiple')
    resource = api.root_resource.find_resource(:invoices)
    expect(resource.member_actions).to have_key(:audit_log)
    expect(resource.collection_actions).to have_key(:search)
  ensure
    Apiwork::API::Registry.unregister('/api/concerns_multiple')
  end

  it 'raises error for unknown concern' do
    expect do
      Apiwork::API.define '/api/concerns_error' do
        resources :invoices, concerns: [:unknown]
      end
    end.to raise_error(Apiwork::ConfigurationError, /No concern named :unknown/)
  ensure
    Apiwork::API::Registry.unregister('/api/concerns_error')
  end
end
