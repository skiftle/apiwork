# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Introspection' do
  before do
    # Ensure API is loaded
    load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)
  end

  describe 'API.as_json' do
    let(:api) { Apiwork::API.find('/api/v1') }
    let(:json) { api.as_json }

    it 'returns complete API structure' do
      expect(json).to be_a(Hash)
      expect(json).to have_key(:path)
      expect(json).to have_key(:metadata)
      expect(json).to have_key(:resources)
    end

    it 'includes correct API path' do
      expect(json[:path]).to eq('/api/v1')
    end

    it 'includes documentation metadata' do
      expect(json[:metadata]).to be_a(Hash)
      expect(json[:metadata][:title]).to eq('Test API')
      expect(json[:metadata][:version]).to eq('1.0.0')
      expect(json[:metadata][:description]).to eq('Test API for Apiwork gem')
    end

    describe 'resources' do
      it 'includes all top-level resources' do
        expect(json[:resources].keys).to include(:posts, :comments, :articles, :persons, :restricted_posts, :safe_comments)
      end

      describe 'posts resource' do
        let(:posts) { json[:resources][:posts] }

        it 'includes resource metadata' do
          expect(posts[:path]).to eq('/api/v1/posts')
          expect(posts[:singular]).to be false
          expect(posts[:actions]).to eq([:index, :show, :create, :update, :destroy])
        end

        it 'includes CRUD action contracts' do
          expect(posts[:contracts]).to have_key(:index)
          expect(posts[:contracts]).to have_key(:show)
          expect(posts[:contracts]).to have_key(:create)
          expect(posts[:contracts]).to have_key(:update)
          expect(posts[:contracts]).to have_key(:destroy)
        end

        it 'includes contract input/output definitions' do
          # Index should have input and output
          expect(posts[:contracts][:index]).to have_key(:input)
          expect(posts[:contracts][:index]).to have_key(:output)

          # Create should have input and output
          expect(posts[:contracts][:create]).to have_key(:input)
          expect(posts[:contracts][:create]).to have_key(:output)
        end

        describe 'member actions' do
          it 'includes all member actions' do
            expect(posts[:members].keys).to contain_exactly(:publish, :archive, :preview)
          end

          it 'includes member action metadata' do
            expect(posts[:members][:publish][:method]).to eq(:patch)
            expect(posts[:members][:publish][:path]).to eq('/api/v1/posts/:id/publish')
          end

          it 'includes member action contract if available' do
            expect(posts[:members][:archive]).to have_key(:contract)
          end
        end

        describe 'collection actions' do
          it 'includes all collection actions' do
            expect(posts[:collections].keys).to contain_exactly(:search, :bulk_create)
          end

          it 'includes collection action metadata' do
            expect(posts[:collections][:search][:method]).to eq(:get)
            expect(posts[:collections][:search][:path]).to eq('/api/v1/posts/search')
          end

          it 'includes collection action contract if available' do
            expect(posts[:collections][:search]).to have_key(:contract)
            expect(posts[:collections][:search][:contract]).to have_key(:input)
            expect(posts[:collections][:search][:contract]).to have_key(:output)
          end
        end

        describe 'nested resources' do
          let(:comments) { posts[:resources][:comments] }

          it 'includes nested resource' do
            expect(posts[:resources]).to have_key(:comments)
          end

          it 'includes correct nested path' do
            expect(comments[:path]).to eq('/api/v1/posts/:post_id/comments')
          end

          it 'includes nested resource actions' do
            expect(comments[:actions]).to eq([:index, :show, :create, :update, :destroy])
          end

          it 'includes nested resource member actions' do
            expect(comments[:members]).to have_key(:approve)
            expect(comments[:members][:approve][:path]).to eq('/api/v1/posts/:post_id/comments/:id/approve')
          end

          it 'includes nested resource collection actions' do
            expect(comments[:collections]).to have_key(:recent)
            expect(comments[:collections][:recent][:path]).to eq('/api/v1/posts/:post_id/comments/recent')
          end
        end
      end

      describe 'restricted_posts resource (only: [:index, :show])' do
        let(:restricted_posts) { json[:resources][:restricted_posts] }

        it 'includes only specified actions' do
          expect(restricted_posts[:actions]).to eq([:index, :show])
        end

        it 'has schema-based contracts generated' do
          # Resources without explicit contract files now have schema-based contracts
          expect(restricted_posts[:contracts]).to be_a(Hash)
          expect(restricted_posts[:contracts]).not_to be_empty
          expect(restricted_posts[:contracts][:index]).to be_present
          expect(restricted_posts[:contracts][:show]).to be_present
        end

        it 'does not include excluded actions in actions list' do
          expect(restricted_posts[:actions]).not_to include(:create, :update, :destroy)
        end
      end

      describe 'safe_comments resource (except: [:destroy])' do
        let(:safe_comments) { json[:resources][:safe_comments] }

        it 'includes all actions except destroyed ones' do
          expect(safe_comments[:actions]).to eq([:index, :show, :create, :update])
        end

        it 'has schema-based contracts generated' do
          # Resources without explicit contract files now have schema-based contracts
          expect(safe_comments[:contracts]).to be_a(Hash)
          expect(safe_comments[:contracts]).not_to be_empty
          expect(safe_comments[:contracts][:index]).to be_present
          expect(safe_comments[:contracts][:create]).to be_present
          expect(safe_comments[:contracts][:show]).to be_present
          expect(safe_comments[:contracts][:update]).to be_present
        end

        it 'does not include excluded destroy action in actions list' do
          expect(safe_comments[:actions]).not_to include(:destroy)
        end
      end
    end
  end

  describe 'nil handling' do
    it 'returns nil when API has no metadata' do
      api_class = Class.new(Apiwork::API::Base)
      expect(api_class.as_json).to be_nil
    end
  end
end
