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

    it 'accepts :underscore format' do
      api_class = Class.new(Apiwork::API::Base) do
        mount '/test'
        path_format :underscore
      end

      expect(api_class.path_format).to eq(:underscore)
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

    context 'with :underscore format' do
      before { api_class.path_format :underscore }

      it 'keeps underscores unchanged' do
        expect(api_class.transform_path_segment(:recurring_invoices)).to eq('recurring_invoices')
      end
    end
  end
end
