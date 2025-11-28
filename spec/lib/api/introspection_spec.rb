# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Introspection' do
  before do
    Apiwork.reset!

    # Load API first so Contracts can find their api_class
    load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)

    # Then reload contract files to ensure action_definitions with custom params are recreated
    load File.expand_path('../../dummy/app/contracts/api/v1/post_contract.rb', __dir__) if defined?(Api::V1::PostContract)
    load File.expand_path('../../dummy/app/contracts/api/v1/article_contract.rb', __dir__) if defined?(Api::V1::ArticleContract)
  end

  describe 'API.as_json' do
    let(:api) { Apiwork::API.find('/api/v1') }
    let(:json) { api.as_json }

    it 'returns complete API structure' do
      expect(json).to be_a(Hash)
      expect(json).to have_key(:path)
      expect(json).to have_key(:info)
      expect(json).to have_key(:resources)
    end

    it 'includes correct API path' do
      expect(json[:path]).to eq('/api/v1')
    end

    it 'includes documentation metadata' do
      expect(json[:info]).to be_a(Hash)
      expect(json[:info][:title]).to eq('Test API')
      expect(json[:info][:version]).to eq('1.0.0')
      expect(json[:info][:description]).to eq('Dummy API for the Apiwork gem')
    end

    describe 'resources' do
      it 'includes all top-level resources' do
        expect(json[:resources].keys).to include(:posts, :comments, :articles, :persons, :restricted_posts,
                                                 :safe_comments)
      end

      describe 'posts resource' do
        let(:posts) { json[:resources][:posts] }

        it 'includes resource path' do
          expect(posts[:path]).to eq('posts')
        end

        it 'includes all CRUD actions' do
          expect(posts[:actions]).to have_key(:index)
          expect(posts[:actions]).to have_key(:show)
          expect(posts[:actions]).to have_key(:create)
          expect(posts[:actions]).to have_key(:update)
          expect(posts[:actions]).to have_key(:destroy)
        end

        it 'includes method and path for CRUD actions' do
          # Index action
          expect(posts[:actions][:index][:method]).to eq(:get)
          expect(posts[:actions][:index][:path]).to eq('/')

          # Show action
          expect(posts[:actions][:show][:method]).to eq(:get)
          expect(posts[:actions][:show][:path]).to eq('/:id')

          # Create action
          expect(posts[:actions][:create][:method]).to eq(:post)
          expect(posts[:actions][:create][:path]).to eq('/')

          # Update action
          expect(posts[:actions][:update][:method]).to eq(:patch)
          expect(posts[:actions][:update][:path]).to eq('/:id')

          # Destroy action
          expect(posts[:actions][:destroy][:method]).to eq(:delete)
          expect(posts[:actions][:destroy][:path]).to eq('/:id')
        end

        it 'includes request/response definitions for CRUD actions' do
          # Index should have request and response
          expect(posts[:actions][:index]).to have_key(:request)
          expect(posts[:actions][:index]).to have_key(:response)

          # Create should have request and response
          expect(posts[:actions][:create]).to have_key(:request)
          expect(posts[:actions][:create]).to have_key(:response)
        end

        describe 'member actions' do
          it 'includes all member actions in actions hash' do
            expect(posts[:actions].keys).to include(:publish, :archive, :preview)
          end

          it 'includes method and path for member actions' do
            expect(posts[:actions][:publish][:method]).to eq(:patch)
            expect(posts[:actions][:publish][:path]).to eq('/:id/publish')
          end

          it 'includes request/response for member actions' do
            expect(posts[:actions][:archive]).to have_key(:request)
            expect(posts[:actions][:archive]).to have_key(:response)
          end

          it 'has both success and error fields in response body' do
            archive = posts[:actions][:archive]
            expect(archive).to have_key(:response)
            response_body = archive[:response][:body]

            # Should be a union with success and error variants
            expect(response_body).to be_a(Hash)
            expect(response_body[:type]).to eq(:union)
            expect(response_body[:variants]).to be_an(Array)
            expect(response_body[:variants].length).to eq(2)

            success_variant = response_body[:variants][0]
            expect(success_variant[:shape].keys).to include(:post)
            expect(success_variant[:shape][:post][:required]).to be(true)

            error_variant = response_body[:variants][1]
            expect(error_variant[:shape].keys).to include(:issues)
            expect(error_variant[:shape][:issues][:required]).to be(true)
          end

          it 'merges custom response params at top level' do
            archive = posts[:actions][:archive]
            response_body = archive[:response][:body]

            # Should be a union with success and error variants
            expect(response_body).to be_a(Hash)
            expect(response_body[:type]).to eq(:union)

            success_variant = response_body[:variants][0]
            # Schema-generated fields
            expect(success_variant[:shape].keys).to include(:post, :meta)
            # Custom response params (defined in PostContract#archive response body)
            expect(success_variant[:shape].keys).to include(:archived_at, :archive_note)

            error_variant = response_body[:variants][1]
            expect(error_variant[:shape].keys).to include(:issues)
          end

          it 'replaces response body completely when response replace: true is used' do
            destroy = posts[:actions][:destroy]
            expect(destroy).to have_key(:response)
            response_body = destroy[:response][:body]

            # Should be a simple object (response replace: true disables merging)
            expect(response_body).to be_a(Hash)
            expect(response_body[:type]).to eq(:object)
            expect(response_body[:shape]).to be_a(Hash)

            # Should only have custom-defined fields
            expect(response_body[:shape].keys).to eq([:deleted_id])
            expect(response_body[:shape][:deleted_id][:type]).to eq(:uuid)
            expect(response_body[:shape][:deleted_id][:required]).to be(true)
          end
        end

        describe 'collection actions' do
          it 'includes all collection actions in actions hash' do
            expect(posts[:actions].keys).to include(:search, :bulk_create)
          end

          it 'includes method and path for collection actions' do
            expect(posts[:actions][:search][:method]).to eq(:get)
            expect(posts[:actions][:search][:path]).to eq('/search')
          end

          it 'includes request/response for collection actions' do
            expect(posts[:actions][:search]).to have_key(:request)
            expect(posts[:actions][:search]).to have_key(:response)
          end

          it 'merges custom response params with collection wrapper at top level' do
            search = posts[:actions][:search]
            response_body = search[:response][:body]

            # Should be a union with success and error variants
            expect(response_body).to be_a(Hash)
            expect(response_body[:type]).to eq(:union)

            success_variant = response_body[:variants][0]
            # Schema-generated fields (from collection wrapper)
            expect(success_variant[:shape].keys).to include(:posts, :meta)
            # Custom response params (defined in PostContract#search response body)
            expect(success_variant[:shape].keys).to include(:search_query, :result_count)

            error_variant = response_body[:variants][1]
            expect(error_variant[:shape].keys).to include(:issues)
          end
        end

        describe 'nested resources' do
          let(:comments) { posts[:resources][:comments] }

          it 'includes nested resource' do
            expect(posts[:resources]).to have_key(:comments)
          end

          it 'includes nested resource path with parent ID' do
            expect(comments[:path]).to eq(':post_id/comments')
          end

          it 'includes correct nested paths for CRUD actions' do
            expect(comments[:actions][:index][:path]).to eq('/')
            expect(comments[:actions][:show][:path]).to eq('/:id')
          end

          it 'includes all nested resource actions' do
            expect(comments[:actions].keys).to include(:index, :show, :create, :update, :destroy)
          end

          it 'includes nested resource member actions' do
            expect(comments[:actions]).to have_key(:approve)
            expect(comments[:actions][:approve][:path]).to eq('/:id/approve')
          end

          it 'includes nested resource collection actions' do
            expect(comments[:actions]).to have_key(:recent)
            expect(comments[:actions][:recent][:path]).to eq('/recent')
          end
        end
      end

      describe 'restricted_posts resource (only: [:index, :show])' do
        let(:restricted_posts) { json[:resources][:restricted_posts] }

        it 'includes only specified actions' do
          expect(restricted_posts[:actions].keys).to contain_exactly(:index, :show)
        end

        it 'has schema-based contracts' do
          # Schema-based contracts derive action definitions from the schema
          expect(restricted_posts[:actions]).to be_a(Hash)
          expect(restricted_posts[:actions]).not_to be_empty
          expect(restricted_posts[:actions][:index]).to be_present
          expect(restricted_posts[:actions][:show]).to be_present
        end

        it 'does not include excluded actions' do
          expect(restricted_posts[:actions].keys).not_to include(:create, :update, :destroy)
        end
      end

      describe 'safe_comments resource (except: [:destroy])' do
        let(:safe_comments) { json[:resources][:safe_comments] }

        it 'includes all actions except destroyed ones' do
          expect(safe_comments[:actions].keys).to contain_exactly(:index, :show, :create, :update)
        end

        it 'has schema-based contracts' do
          # Schema-based contracts derive action definitions from the schema
          expect(safe_comments[:actions]).to be_a(Hash)
          expect(safe_comments[:actions]).not_to be_empty
          expect(safe_comments[:actions][:index]).to be_present
          expect(safe_comments[:actions][:create]).to be_present
          expect(safe_comments[:actions][:show]).to be_present
          expect(safe_comments[:actions][:update]).to be_present
        end

        it 'does not include excluded destroy action' do
          expect(safe_comments[:actions].keys).not_to include(:destroy)
        end
      end
    end
  end

  describe 'error_codes' do
    let(:api) { Apiwork::API.find('/api/v1') }
    let(:json) { api.as_json }

    it 'includes API-level global error codes at root level' do
      expect(json[:error_codes]).to eq([400, 500])
    end

    context 'when action has no specific error codes' do
      it 'has empty array for index action (only global codes apply)' do
        index_action = json[:resources][:posts][:actions][:index]
        # Index has no action-specific codes, so empty array
        # Consumers merge: api.error_codes + action.error_codes
        expect(index_action[:error_codes]).to eq([])
      end
    end

    context 'when action has specific error codes' do
      it 'includes only action-specific codes for show action' do
        show_action = json[:resources][:posts][:actions][:show]
        # PostContract#show has error_codes 404, 403
        # Global codes (400, 500) are NOT included - they're in json[:error_codes]
        expect(show_action[:error_codes]).to contain_exactly(403, 404)
      end

      it 'keeps codes unique and sorted' do
        show_action = json[:resources][:posts][:actions][:show]
        codes = show_action[:error_codes]
        expect(codes).to eq(codes.uniq.sort)
      end

      it 'includes only auto-generated 422 for create action' do
        create_action = json[:resources][:posts][:actions][:create]
        # PostContract#create has error_codes 422 (manual)
        # Auto-generated 422 is merged with manual
        # Global codes (400, 500) are NOT included
        expect(create_action[:error_codes]).to eq([422])
      end

      it 'has different codes for different actions' do
        show_action = json[:resources][:posts][:actions][:show]
        create_action = json[:resources][:posts][:actions][:create]
        update_action = json[:resources][:posts][:actions][:update]

        # show: 403, 404 (action-specific)
        expect(show_action[:error_codes]).to contain_exactly(403, 404)

        # create: 422 (manual + auto merged)
        expect(create_action[:error_codes]).to eq([422])

        # update: 404 (action-specific), 422 (auto-generated)
        expect(update_action[:error_codes]).to contain_exactly(404, 422)
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
