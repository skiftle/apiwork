# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Base do
  describe '.adapter' do
    it 'returns the adapter' do
      api_class = Apiwork::API.define('/unit/base-adapter') {}

      expect(api_class.adapter).to be_a(Apiwork::Adapter::Base)
    end
  end

  describe '.enum' do
    it 'registers the enum' do
      api_class = Apiwork::API.define '/unit/base-enum' do
        enum :status, values: %w[draft sent paid]
      end

      expect(api_class.enum_registry.exists?(:status)).to be(true)
    end
  end

  describe '.export' do
    it 'enables the export' do
      api_class = Apiwork::API.define '/unit/base-export' do
        export :openapi
      end

      expect(api_class.export_configs).to have_key(:openapi)
    end
  end

  describe '.fragment' do
    it 'registers the fragment' do
      api_class = Apiwork::API.define '/unit/base-fragment' do
        fragment :timestamps do
          datetime :created_at
        end
      end

      expect(api_class.type_registry.exists?(:timestamps)).to be(true)
    end
  end

  describe '.info' do
    it 'defines the info' do
      api_class = Apiwork::API.define '/unit/base-info' do
        info do
          title 'Invoice API'
          version '1.0.0'
        end
      end

      expect(api_class.info).to be_a(Apiwork::API::Info)
      expect(api_class.info.title).to eq('Invoice API')
    end
  end

  describe '.key_format' do
    it 'returns the key format' do
      api_class = Apiwork::API.define '/unit/base-key-format' do
        key_format :camel
      end

      expect(api_class.key_format).to eq(:camel)
    end

    it 'returns :keep when not set' do
      api_class = Apiwork::API.define('/unit/base-key-format-default') {}

      expect(api_class.key_format).to eq(:keep)
    end

    it 'raises ConfigurationError for invalid format' do
      expect do
        Apiwork::API.define '/unit/base-key-format-invalid' do
          key_format :invalid
        end
      end.to raise_error(Apiwork::ConfigurationError, /key_format/)
    end
  end

  describe '.object' do
    it 'registers the object' do
      api_class = Apiwork::API.define '/unit/base-object' do
        object :item do
          string :title
          decimal :amount
        end
      end

      expect(api_class.type_registry.exists?(:item)).to be(true)
    end
  end

  describe '.path_format' do
    it 'returns the path format' do
      api_class = Apiwork::API.define '/unit/base-path-format' do
        path_format :kebab
      end

      expect(api_class.path_format).to eq(:kebab)
    end

    it 'returns :keep when not set' do
      api_class = Apiwork::API.define('/unit/base-path-format-default') {}

      expect(api_class.path_format).to eq(:keep)
    end

    it 'raises ConfigurationError for invalid format' do
      expect do
        Apiwork::API.define '/unit/base-path-format-invalid' do
          path_format :invalid
        end
      end.to raise_error(Apiwork::ConfigurationError, /path_format/)
    end
  end

  describe '.raises' do
    it 'returns the error codes' do
      api_class = Apiwork::API.define '/unit/base-raises' do
        raises :unauthorized, :forbidden
      end

      expect(api_class.raises).to eq(%i[unauthorized forbidden])
    end

    it 'raises ConfigurationError for non-symbol' do
      expect do
        Apiwork::API.define '/unit/base-raises-invalid' do
          raises 404
        end
      end.to raise_error(Apiwork::ConfigurationError, /raises must be symbols/)
    end
  end

  describe '.resources' do
    it 'defines the resource' do
      api_class = Apiwork::API.define '/unit/base-resources' do
        resources :invoices
      end

      expect(api_class.root_resource.resources).to have_key(:invoices)
    end
  end

  describe '.union' do
    it 'registers the union' do
      api_class = Apiwork::API.define '/unit/base-union' do
        union :payment_method, discriminator: :type do
          variant tag: 'card' do
            object do
              string :last_four
            end
          end
        end
      end

      expect(api_class.type_registry.exists?(:payment_method)).to be(true)
    end
  end
end
