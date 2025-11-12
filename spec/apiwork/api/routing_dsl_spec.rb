# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Apiwork Routing DSL' do
  let(:metadata) { Apiwork::API::Metadata.new('/api/v1') }
  let(:recorder) { Apiwork::API::Recorder.new(metadata, [:api, :v1]) }

  describe 'member actions' do
    context 'with member block syntax' do
      it 'captures single action' do
        recorder.instance_eval do
          resources :posts do
            member do
              patch :archive
            end
          end
        end

        members = metadata.resources[:posts][:members]
        expect(members).to have_key(:archive)
        expect(members[:archive][:method]).to eq(:patch)
      end

      it 'captures multiple actions' do
        recorder.instance_eval do
          resources :posts do
            member do
              patch :archive
              patch :unarchive
              get :preview
            end
          end
        end

        members = metadata.resources[:posts][:members]
        expect(members).to have_key(:archive)
        expect(members).to have_key(:unarchive)
        expect(members).to have_key(:preview)
        expect(members[:preview][:method]).to eq(:get)
      end

      it 'supports all HTTP verbs' do
        recorder.instance_eval do
          resources :posts do
            member do
              get :preview
              post :publish
              patch :rename
              put :replace
              delete :remove
            end
          end
        end

        members = metadata.resources[:posts][:members]
        expect(members[:preview][:method]).to eq(:get)
        expect(members[:publish][:method]).to eq(:post)
        expect(members[:rename][:method]).to eq(:patch)
        expect(members[:replace][:method]).to eq(:put)
        expect(members[:remove][:method]).to eq(:delete)
      end
    end

    context 'with inline on: :member syntax' do
      it 'captures single action' do
        recorder.instance_eval do
          resources :posts do
            patch :archive, on: :member
          end
        end

        members = metadata.resources[:posts][:members]
        expect(members).to have_key(:archive)
        expect(members[:archive][:method]).to eq(:patch)
      end

      it 'captures multiple actions declared separately' do
        recorder.instance_eval do
          resources :posts do
            patch :archive, on: :member
            get :preview, on: :member
          end
        end

        members = metadata.resources[:posts][:members]
        expect(members).to have_key(:archive)
        expect(members).to have_key(:preview)
      end
    end

    context 'with array of actions' do
      it 'captures all actions in array' do
        recorder.instance_eval do
          resources :posts do
            patch %i[archive unarchive], on: :member
          end
        end

        members = metadata.resources[:posts][:members]
        expect(members).to have_key(:archive)
        expect(members).to have_key(:unarchive)
        expect(members[:archive][:method]).to eq(:patch)
        expect(members[:unarchive][:method]).to eq(:patch)
      end

      it 'works in member blocks' do
        recorder.instance_eval do
          resources :posts do
            member do
              get %i[preview history]
            end
          end
        end

        members = metadata.resources[:posts][:members]
        expect(members).to have_key(:preview)
        expect(members).to have_key(:history)
      end
    end
  end

  describe 'collection actions' do
    context 'with collection block syntax' do
      it 'captures single action' do
        recorder.instance_eval do
          resources :posts do
            collection do
              get :search
            end
          end
        end

        collections = metadata.resources[:posts][:collections]
        expect(collections).to have_key(:search)
        expect(collections[:search][:method]).to eq(:get)
      end

      it 'captures multiple actions' do
        recorder.instance_eval do
          resources :posts do
            collection do
              get :search
              post :import
              post :export
            end
          end
        end

        collections = metadata.resources[:posts][:collections]
        expect(collections).to have_key(:search)
        expect(collections).to have_key(:import)
        expect(collections).to have_key(:export)
      end

      it 'supports all HTTP verbs' do
        recorder.instance_eval do
          resources :posts do
            collection do
              get :search
              post :bulk_create
              patch :bulk_update
              put :bulk_replace
              delete :bulk_delete
            end
          end
        end

        collections = metadata.resources[:posts][:collections]
        expect(collections[:search][:method]).to eq(:get)
        expect(collections[:bulk_create][:method]).to eq(:post)
        expect(collections[:bulk_update][:method]).to eq(:patch)
        expect(collections[:bulk_replace][:method]).to eq(:put)
        expect(collections[:bulk_delete][:method]).to eq(:delete)
      end
    end

    context 'with inline on: :collection syntax' do
      it 'captures single action' do
        recorder.instance_eval do
          resources :posts do
            get :search, on: :collection
          end
        end

        collections = metadata.resources[:posts][:collections]
        expect(collections).to have_key(:search)
        expect(collections[:search][:method]).to eq(:get)
      end

      it 'captures multiple actions declared separately' do
        recorder.instance_eval do
          resources :posts do
            get :search, on: :collection
            post :import, on: :collection
          end
        end

        collections = metadata.resources[:posts][:collections]
        expect(collections).to have_key(:search)
        expect(collections).to have_key(:import)
      end
    end

    context 'with array of actions' do
      it 'captures all actions in array' do
        recorder.instance_eval do
          resources :posts do
            post %i[import export], on: :collection
          end
        end

        collections = metadata.resources[:posts][:collections]
        expect(collections).to have_key(:import)
        expect(collections).to have_key(:export)
        expect(collections[:import][:method]).to eq(:post)
        expect(collections[:export][:method]).to eq(:post)
      end

      it 'works in collection blocks' do
        recorder.instance_eval do
          resources :posts do
            collection do
              get %i[search filter]
            end
          end
        end

        collections = metadata.resources[:posts][:collections]
        expect(collections).to have_key(:search)
        expect(collections).to have_key(:filter)
      end
    end
  end

  describe 'validation and error handling' do
    context 'when action declared without member/collection context' do
      it 'raises ConfigurationError with helpful message' do
        expect do
          recorder.instance_eval do
            resources :posts do
              patch :archive
            end
          end
        end.to raise_error(
          Apiwork::ConfigurationError,
          /Action 'archive' on resource 'posts' must be declared/
        )
      end

      it 'error message includes examples' do
        expect do
          recorder.instance_eval do
            resources :posts do
              get :preview
            end
          end
        end.to raise_error(
          Apiwork::ConfigurationError,
          /member \{ get :preview \}/
        )
      end
    end

    context 'when :on parameter has invalid value' do
      it 'raises ConfigurationError for :on => :invalid' do
        expect do
          recorder.instance_eval do
            resources :posts do
              patch :archive, on: :invalid
            end
          end
        end.to raise_error(
          Apiwork::ConfigurationError,
          /:on option must be either :member or :collection, got :invalid/
        )
      end

      it 'raises ConfigurationError for :on => "member"' do
        expect do
          recorder.instance_eval do
            resources :posts do
              patch :archive, on: 'member'
            end
          end
        end.to raise_error(
          Apiwork::ConfigurationError,
          /:on option must be either :member or :collection, got "member"/
        )
      end
    end
  end

  describe 'mixed member and collection actions' do
    it 'captures both types correctly' do
      recorder.instance_eval do
        resources :posts do
          member do
            patch :archive
            get :preview
          end

          collection do
            get :search
            post :import
          end
        end
      end

      members = metadata.resources[:posts][:members]
      collections = metadata.resources[:posts][:collections]

      expect(members).to have_key(:archive)
      expect(members).to have_key(:preview)
      expect(collections).to have_key(:search)
      expect(collections).to have_key(:import)
    end

    it 'allows mixing block and inline syntax' do
      recorder.instance_eval do
        resources :posts do
          member do
            patch :archive
          end

          get :preview, on: :member
          get :search, on: :collection
        end
      end

      members = metadata.resources[:posts][:members]
      collections = metadata.resources[:posts][:collections]

      expect(members).to have_key(:archive)
      expect(members).to have_key(:preview)
      expect(collections).to have_key(:search)
    end
  end

  describe 'nested resources' do
    it 'supports member/collection actions in nested resources' do
      recorder.instance_eval do
        resources :accounts do
          resources :posts do
            member do
              patch :archive
            end

            collection do
              get :search
            end
          end
        end
      end

      posts_metadata = metadata.resources[:accounts][:resources][:posts]
      expect(posts_metadata[:members]).to have_key(:archive)
      expect(posts_metadata[:collections]).to have_key(:search)
    end
  end

  describe 'singular resources' do
    it 'captures actions on singular resource' do
      recorder.instance_eval do
        resource :account do
          member do
            get :dashboard
          end
        end
      end

      # Singular resources store in same structure
      account_metadata = metadata.resources[:account]
      expect(account_metadata[:members]).to have_key(:dashboard)
    end

    it 'allows on: :member for singular resources' do
      recorder.instance_eval do
        resource :account do
          get :dashboard, on: :member
        end
      end

      account_metadata = metadata.resources[:account]
      expect(account_metadata[:members]).to have_key(:dashboard)
    end
  end
end
