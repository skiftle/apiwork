# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Resource do
  describe '#collection' do
    it 'defines a collection action' do
      api_class = Apiwork::API.define '/unit/resource-collection' do
        resources :invoices do
          collection do
            get :search
          end
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.collection_actions).to have_key(:search)
    end
  end

  describe '#concern' do
    it 'defines the concern' do
      api_class = Apiwork::API.define '/unit/resource-concern' do
        concern :archivable do
          member do
            post :archive
          end
        end
        resources :invoices, concerns: [:archivable]
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.member_actions).to have_key(:archive)
    end
  end

  describe '#concerns' do
    it 'applies the concerns' do
      api_class = Apiwork::API.define '/unit/resource-concerns' do
        concern :archivable do
          member do
            post :archive
          end
        end
        concern :searchable do
          collection do
            get :search
          end
        end
        resources :invoices do
          concerns :archivable, :searchable
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.member_actions).to have_key(:archive)
      expect(resource.collection_actions).to have_key(:search)
    end
  end

  describe '#delete' do
    it 'defines a DELETE action' do
      api_class = Apiwork::API.define '/unit/resource-delete' do
        resources :invoices do
          member do
            delete :archive
          end
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.member_actions[:archive].method).to eq(:delete)
    end
  end

  describe '#get' do
    it 'defines a GET action' do
      api_class = Apiwork::API.define '/unit/resource-get' do
        resources :invoices do
          member do
            get :preview
          end
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.member_actions).to have_key(:preview)
    end

    context 'with on: :collection' do
      it 'defines a collection action' do
        api_class = Apiwork::API.define '/unit/resource-get-on' do
          resources :invoices do
            get :search, on: :collection
          end
        end

        resource = api_class.root_resource.resources[:invoices]
        expect(resource.collection_actions).to have_key(:search)
      end
    end
  end

  describe '#member' do
    it 'defines a member action' do
      api_class = Apiwork::API.define '/unit/resource-member' do
        resources :invoices do
          member do
            post :send_invoice
          end
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.member_actions).to have_key(:send_invoice)
    end
  end

  describe '#patch' do
    it 'defines a PATCH action' do
      api_class = Apiwork::API.define '/unit/resource-patch' do
        resources :invoices do
          member do
            patch :mark_paid
          end
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.member_actions[:mark_paid].method).to eq(:patch)
    end
  end

  describe '#post' do
    it 'defines a POST action' do
      api_class = Apiwork::API.define '/unit/resource-post' do
        resources :invoices do
          member do
            post :archive
          end
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.member_actions[:archive].method).to eq(:post)
    end
  end

  describe '#put' do
    it 'defines a PUT action' do
      api_class = Apiwork::API.define '/unit/resource-put' do
        resources :invoices do
          member do
            put :replace
          end
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.member_actions[:replace].method).to eq(:put)
    end
  end

  describe '#resource' do
    it 'defines a singular resource' do
      api_class = Apiwork::API.define '/unit/resource-resource' do
        resource :profile
      end

      expect(api_class.root_resource.resources).to have_key(:profile)
      expect(api_class.root_resource.resources[:profile].singular).to be(true)
    end
  end

  describe '#resources' do
    it 'defines a plural resource' do
      api_class = Apiwork::API.define '/unit/resource-resources' do
        resources :invoices
      end

      expect(api_class.root_resource.resources).to have_key(:invoices)
    end

    it 'defines nested resources' do
      api_class = Apiwork::API.define '/unit/resource-resources-nested' do
        resources :invoices do
          resources :items
        end
      end

      invoice_resource = api_class.root_resource.resources[:invoices]
      expect(invoice_resource.resources).to have_key(:items)
    end

    context 'with options' do
      it 'forwards all options' do
        api_class = Apiwork::API.define '/unit/resource-resources-options' do
          resources :invoices,
                    controller: 'billing/invoices',
                    except: [:destroy],
                    only: [:index, :show],
                    param: :invoice_number,
                    path: 'bills'
        end

        resource = api_class.root_resource.resources[:invoices]
        expect(resource.controller).to eq('billing/invoices')
        expect(resource.except).to eq([:destroy])
        expect(resource.only).to eq([:index, :show])
        expect(resource.param).to eq(:invoice_number)
        expect(resource.path).to eq('bills')
      end
    end
  end

  describe '#with_options' do
    it 'forwards the options' do
      api_class = Apiwork::API.define '/unit/resource-with-options' do
        with_options only: [:index, :show] do
          resources :invoices
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.only).to eq([:index, :show])
    end
  end
end
