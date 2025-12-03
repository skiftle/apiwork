# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Type Descriptions', type: :integration do
  before(:all) do
    Apiwork.reset!
    load Rails.root.join('config/apis/v1.rb')
  end

  describe 'Global types' do
    let(:introspection) { Apiwork::API.introspect('/api/v1') }

    it 'includes description for string_filter type' do
      expect(introspection[:types]).to have_key(:string_filter)
      expect(introspection[:types][:string_filter][:description]).to eq('String filter operators')
    end

    it 'includes description for integer_filter type' do
      expect(introspection[:types]).to have_key(:integer_filter)
      expect(introspection[:types][:integer_filter][:description]).to eq('Integer filter operators')
    end

    it 'includes description for page_pagination type' do
      expect(introspection[:types]).to have_key(:page_pagination)
      expect(introspection[:types][:page_pagination][:description]).to eq('Page-based pagination info')
    end

    it 'includes description for issue type' do
      expect(introspection[:types]).to have_key(:issue)
      expect(introspection[:types][:issue][:description]).to eq('Validation issue details')
    end
  end

  describe 'Schema-generated types' do
    let(:introspection) { Apiwork::API.introspect('/api/v1') }

    it 'includes description with model name for filter types' do
      expect(introspection[:types]).to have_key(:post_filter)
      expect(introspection[:types][:post_filter][:description]).to eq('Filter options for Post')
    end

    it 'includes description with model name for sort types' do
      expect(introspection[:types]).to have_key(:post_sort)
      expect(introspection[:types][:post_sort][:description]).to eq('Sort options for Post')
    end

    it 'includes description with model name for create_payload types' do
      expect(introspection[:types]).to have_key(:post_create_payload)
      expect(introspection[:types][:post_create_payload][:description]).to eq('Payload for creating a Post')
    end

    it 'includes description with model name for update_payload types' do
      expect(introspection[:types]).to have_key(:post_update_payload)
      expect(introspection[:types][:post_update_payload][:description]).to eq('Payload for updating a Post')
    end
  end

  describe 'Enums' do
    let(:introspection) { Apiwork::API.introspect('/api/v1') }

    it 'includes description for sort_direction enum' do
      expect(introspection[:enums]).to have_key(:sort_direction)
      expect(introspection[:enums][:sort_direction][:description]).to eq('Sort direction (asc/desc)')
    end
  end

  describe 'i18n API-specific overrides' do
    before(:all) do
      @override_api = Apiwork::API.draw '/api/override_test' do
        spec :openapi

        resources :posts
      end

      I18n.backend.store_translations(:en, {
                                        apiwork: {
                                          apis: {
                                            'api/override_test' => {
                                              types: {
                                                post_filter: { description: 'Custom filter for posts' }
                                              }
                                            }
                                          }
                                        }
                                      })
    end

    after(:all) do
      Apiwork::API::Registry.unregister('/api/override_test')
      I18n.backend.reload!
      I18n.backend.load_translations
    end

    it 'uses API-specific description when available' do
      introspection = Apiwork::API.introspect('/api/override_test')

      expect(introspection[:types][:post_filter][:description]).to eq('Custom filter for posts')
    end
  end
end
