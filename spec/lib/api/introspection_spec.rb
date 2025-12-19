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
            expect(success_variant[:shape][:post][:optional]).to be_nil

            error_variant = response_body[:variants][1]
            expect(error_variant[:shape].keys).to include(:errors)
            expect(error_variant[:shape][:errors][:optional]).to be(true)
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
            expect(error_variant[:shape].keys).to include(:errors)
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
            expect(response_body[:shape][:deleted_id][:optional]).to be_nil
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
            expect(error_variant[:shape].keys).to include(:errors)
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

  describe 'raises and error_codes' do
    let(:api) { Apiwork::API.find('/api/v1') }
    let(:json) { api.as_json }

    it 'includes API-level raises at root level' do
      expect(json[:raises]).to contain_exactly(:bad_request, :internal_server_error)
    end

    it 'includes error_codes hash with status and description for all used error codes' do
      expect(json[:error_codes].keys).to include(:bad_request, :internal_server_error, :not_found, :forbidden, :unprocessable_entity)
      expect(json[:error_codes][:bad_request]).to eq({ status: 400, description: 'Bad Request' })
      expect(json[:error_codes][:not_found]).to eq({ status: 404, description: 'Not Found' })
    end

    context 'when action has no specific raises' do
      it 'does not include raises key for index action (API-level raises apply implicitly)' do
        index_action = json[:resources][:posts][:actions][:index]
        expect(index_action).not_to have_key(:raises)
      end
    end

    context 'when action has specific raises' do
      it 'includes only action-specific codes for show action (not API-level)' do
        show_action = json[:resources][:posts][:actions][:show]
        expect(show_action[:raises]).to contain_exactly(:forbidden, :not_found)
      end

      it 'keeps codes unique and sorted alphabetically' do
        show_action = json[:resources][:posts][:actions][:show]
        codes = show_action[:raises]
        expect(codes).to eq(codes.uniq.sort_by(&:to_s))
      end

      it 'includes only auto-generated :unprocessable_entity for create action' do
        create_action = json[:resources][:posts][:actions][:create]
        expect(create_action[:raises]).to contain_exactly(:unprocessable_entity)
      end

      it 'has different codes for different actions (only action-specific, not API-level)' do
        show_action = json[:resources][:posts][:actions][:show]
        create_action = json[:resources][:posts][:actions][:create]
        update_action = json[:resources][:posts][:actions][:update]

        expect(show_action[:raises]).to contain_exactly(:forbidden, :not_found)
        expect(create_action[:raises]).to contain_exactly(:unprocessable_entity)
        expect(update_action[:raises]).to contain_exactly(:not_found, :unprocessable_entity)
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
