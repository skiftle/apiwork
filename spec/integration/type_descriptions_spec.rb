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

    it 'has no auto-generated description for filter types' do
      expect(introspection[:types]).to have_key(:post_filter)
      expect(introspection[:types][:post_filter][:description]).to be_nil
    end

    it 'has no auto-generated description for sort types' do
      expect(introspection[:types]).to have_key(:post_sort)
      expect(introspection[:types][:post_sort][:description]).to be_nil
    end

    it 'has no auto-generated description for create_payload types' do
      expect(introspection[:types]).to have_key(:post_create_payload)
      expect(introspection[:types][:post_create_payload][:description]).to be_nil
    end

    it 'has no auto-generated description for update_payload types' do
      expect(introspection[:types]).to have_key(:post_update_payload)
      expect(introspection[:types][:post_update_payload][:description]).to be_nil
    end
  end

  describe 'Enums' do
    let(:introspection) { Apiwork::API.introspect('/api/v1') }

    it 'includes description for sort_direction enum' do
      expect(introspection[:enums]).to have_key(:sort_direction)
      expect(introspection[:enums][:sort_direction][:description]).to eq('Sort direction (asc/desc)')
    end
  end

  describe 'Schema description DSL' do
    let(:introspection) { Apiwork::API.introspect('/api/v1') }

    it 'uses schema description for resource type' do
      expect(introspection[:types][:article][:description]).to eq('A news article')
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

  describe 'Type merging' do
    before(:all) do
      @merge_api = Apiwork::API.draw '/api/merge_test' do
        spec :openapi

        type :base_type do
          param :name, type: :string
          param :age, type: :integer
        end

        type :base_type, description: 'A base type with name and age'

        type :base_type do
          param :email, type: :string, description: 'Email address'
        end

        type :base_type do
          param :age, description: 'Age in years'
        end

        enum :status, values: %w[active inactive]

        enum :status, description: 'Account status'
      end
    end

    after(:all) do
      Apiwork::API::Registry.unregister('/api/merge_test')
    end

    let(:introspection) { Apiwork::API.introspect('/api/merge_test') }

    it 'merges type description' do
      expect(introspection[:types][:base_type][:description]).to eq('A base type with name and age')
    end

    it 'merges new params into existing type' do
      shape = introspection[:types][:base_type][:shape]
      param_names = shape.keys
      expect(param_names).to include(:name, :age, :email)
    end

    it 'merges param metadata into existing param' do
      shape = introspection[:types][:base_type][:shape]
      expect(shape[:age][:description]).to eq('Age in years')
      expect(shape[:email][:description]).to eq('Email address')
    end

    it 'merges enum description' do
      expect(introspection[:enums][:status][:description]).to eq('Account status')
      expect(introspection[:enums][:status][:values]).to eq(%w[active inactive])
    end
  end

  describe 'Nested object merging' do
    before(:all) do
      @nested_api = Apiwork::API.draw '/api/nested_test' do
        spec :openapi

        type :address do
          param :street, type: :string
        end

        type :address, description: 'A physical address'

        type :address do
          param :city, type: :string
          param :street, description: 'Street name'
        end

        type :address do
          param :country, type: :string
        end

        type :with_nested do
          param :location, type: :object, description: 'Location info'
        end

        type :with_nested do
          param :location do
            param :lat, type: :decimal
            param :lng, type: :decimal
          end
        end

        type :with_nested do
          param :location do
            param :label, type: :string
          end
        end
      end
    end

    after(:all) do
      Apiwork::API::Registry.unregister('/api/nested_test')
    end

    let(:introspection) { Apiwork::API.introspect('/api/nested_test') }

    it 'merges nested params across multiple declarations' do
      shape = introspection[:types][:address][:shape]
      expect(shape.keys).to include(:street, :city, :country)
    end

    it 'merges param metadata in nested types' do
      shape = introspection[:types][:address][:shape]
      expect(shape[:street][:description]).to eq('Street name')
    end

    it 'creates shape when adding nested params to existing param without shape' do
      shape = introspection[:types][:with_nested][:shape]
      expect(shape[:location][:description]).to eq('Location info')
      expect(shape[:location][:shape]).to be_present
    end

    it 'merges nested object params across declarations' do
      location_shape = introspection[:types][:with_nested][:shape][:location][:shape]
      expect(location_shape.keys).to include(:lat, :lng, :label)
    end
  end

  describe 'Contract-scoped type merging' do
    before(:all) do
      Apiwork.reset!
      load Rails.root.join('config/apis/v1.rb')
    end

    let(:introspection) { Apiwork::API.introspect('/api/v1') }

    it 'can merge description via Contract after adapter generates type' do
      Api::V1::PostContract.type :filter, description: 'Filter posts by various criteria'

      Apiwork.reset!
      load Rails.root.join('config/apis/v1.rb')
      Api::V1::PostContract.type :filter, description: 'Filter posts by various criteria'

      fresh_introspection = Apiwork::API.introspect('/api/v1')

      expect(fresh_introspection[:types][:post_filter][:description]).to eq('Filter posts by various criteria')
    end

    it 'can add new param via Contract after adapter generates type' do
      Api::V1::PostContract.type :filter do
        param :search, type: :string, description: 'Full text search'
      end

      Apiwork.reset!
      load Rails.root.join('config/apis/v1.rb')
      Api::V1::PostContract.type :filter do
        param :search, type: :string, description: 'Full text search'
      end

      fresh_introspection = Apiwork::API.introspect('/api/v1')
      shape = fresh_introspection[:types][:post_filter][:shape]

      expect(shape).to have_key(:search)
      expect(shape[:search][:description]).to eq('Full text search')
    end
  end
end
