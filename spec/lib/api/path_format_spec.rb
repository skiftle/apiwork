# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API path_format' do
  describe 'path_format setting' do
    after { Apiwork::API::Registry.clear! }

    it 'defaults to :keep' do
      api_class = Class.new(Apiwork::API::Base) do
        mount '/test'
      end

      expect(api_class.path_format).to eq(:keep)
    end

    it 'accepts :kebab format' do
      api_class = Class.new(Apiwork::API::Base) do
        mount '/test'
        path_format :kebab
      end

      expect(api_class.path_format).to eq(:kebab)
    end

    it 'accepts :camel format' do
      api_class = Class.new(Apiwork::API::Base) do
        mount '/test'
        path_format :camel
      end

      expect(api_class.path_format).to eq(:camel)
    end

    it 'raises error for invalid format' do
      expect do
        Class.new(Apiwork::API::Base) do
          mount '/test'
          path_format :invalid
        end
      end.to raise_error(Apiwork::ConfigurationError, /path_format must be one of/)
    end
  end

  describe 'transform_path_segment' do
    after { Apiwork::API::Registry.clear! }

    let(:api_class) do
      Class.new(Apiwork::API::Base) do
        mount '/test'
      end
    end

    context 'with :keep format' do
      before { api_class.path_format :keep }

      it 'keeps underscore segments unchanged' do
        expect(api_class.transform_path_segment(:recurring_invoices)).to eq('recurring_invoices')
      end
    end

    context 'with :kebab format' do
      before { api_class.path_format :kebab }

      it 'transforms underscores to dashes' do
        expect(api_class.transform_path_segment(:recurring_invoices)).to eq('recurring-invoices')
      end

      it 'handles single-word segments' do
        expect(api_class.transform_path_segment(:invoices)).to eq('invoices')
      end

      it 'handles multiple underscores' do
        expect(api_class.transform_path_segment(:very_long_resource_name)).to eq('very-long-resource-name')
      end
    end

    context 'with :camel format' do
      before { api_class.path_format :camel }

      it 'transforms to lowerCamelCase' do
        expect(api_class.transform_path_segment(:recurring_invoices)).to eq('recurringInvoices')
      end

      it 'handles single-word segments' do
        expect(api_class.transform_path_segment(:invoices)).to eq('invoices')
      end

      it 'handles multiple underscores' do
        expect(api_class.transform_path_segment(:very_long_resource_name)).to eq('veryLongResourceName')
      end
    end
  end

  describe 'introspection with path_format' do
    before(:all) do
      @kebab_api = Apiwork::API.define '/api/path_format_kebab' do
        path_format :kebab

        resources :recurring_invoices, only: [:index, :show] do
          member do
            patch :mark_as_paid
          end
          collection do
            get :past_due
          end
          resources :line_items, only: [:index]
        end
      end

      @camel_api = Apiwork::API.define '/api/path_format_camel' do
        path_format :camel

        resources :recurring_invoices, only: [:index]
      end

      @override_api = Apiwork::API.define '/api/path_format_override' do
        path_format :kebab

        resources :recurring_invoices, only: [:index], path: 'invoices'
      end
    end

    after(:all) do
      Apiwork::API::Registry.unregister('/api/path_format_kebab')
      Apiwork::API::Registry.unregister('/api/path_format_camel')
      Apiwork::API::Registry.unregister('/api/path_format_override')
    end

    context 'with :kebab format' do
      let(:api) { @kebab_api } # rubocop:disable RSpec/InstanceVariable
      let(:introspection) { api.introspect }

      it 'transforms resource path to kebab-case' do
        resource = introspection[:resources][:recurring_invoices]
        expect(resource[:path]).to eq('recurring-invoices')
      end

      it 'keeps identifier as original name' do
        resource = introspection[:resources][:recurring_invoices]
        expect(resource[:identifier]).to eq('recurring_invoices')
      end

      it 'transforms member action paths' do
        resource = introspection[:resources][:recurring_invoices]
        expect(resource[:actions][:mark_as_paid][:path]).to eq('/:id/mark-as-paid')
      end

      it 'transforms collection action paths' do
        resource = introspection[:resources][:recurring_invoices]
        expect(resource[:actions][:past_due][:path]).to eq('/past-due')
      end

      it 'transforms nested resource path' do
        nested = introspection[:resources][:recurring_invoices][:resources][:line_items]
        expect(nested[:path]).to eq(':recurring_invoice_id/line-items')
      end
    end

    context 'with :camel format' do
      let(:api) { @camel_api } # rubocop:disable RSpec/InstanceVariable
      let(:introspection) { api.introspect }

      it 'transforms resource path to camelCase' do
        resource = introspection[:resources][:recurring_invoices]
        expect(resource[:path]).to eq('recurringInvoices')
      end
    end

    context 'with explicit path: override' do
      let(:api) { @override_api } # rubocop:disable RSpec/InstanceVariable
      let(:introspection) { api.introspect }

      it 'uses explicit path instead of transformed name' do
        resource = introspection[:resources][:recurring_invoices]
        expect(resource[:path]).to eq('invoices')
      end

      it 'keeps identifier as original name' do
        resource = introspection[:resources][:recurring_invoices]
        expect(resource[:identifier]).to eq('recurring_invoices')
      end
    end
  end
end
