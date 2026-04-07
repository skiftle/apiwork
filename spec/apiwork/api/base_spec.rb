# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Base do
  describe '.adapter' do
    it 'returns the adapter' do
      api_class = Apiwork::API.define('/unit/base-adapter') {}

      expect(api_class.adapter).to be_a(Apiwork::Adapter::Base)
    end
  end

  describe '.concern' do
    it 'defines a concern' do
      api_class = Apiwork::API.define '/unit/base-concern' do
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

  describe '.enum' do
    it 'registers the enum' do
      api_class = Apiwork::API.define '/unit/base-enum' do
        enum :status, values: %w[draft sent paid]
      end

      expect(api_class.enum_registry.exists?(:status)).to be(true)
    end
  end

  describe '.explorer' do
    it 'raises ConfigurationError when gem is not installed' do
      expect do
        Apiwork::API.define '/unit/base-explorer-missing' do
          explorer
        end
      end.to raise_error(Apiwork::ConfigurationError, /apiwork-explorer/)
    end

    context 'when gem is installed' do
      before { stub_const('Apiwork::Explorer::Engine', Class.new) }

      context 'with defaults' do
        it 'enables the explorer' do
          api_class = Apiwork::API.define '/unit/base-explorer' do
            explorer
          end

          expect(api_class.explorer_config).to be_a(Apiwork::Configuration)
          expect(api_class.explorer_config.mode).to eq(:auto)
          expect(api_class.explorer_config.path).to eq('/.explorer')
        end
      end

      context 'with overrides' do
        it 'forwards all options' do
          api_class = Apiwork::API.define '/unit/base-explorer-block' do
            explorer do
              mode :always
              path '/explorer'
            end
          end

          expect(api_class.explorer_config.mode).to eq(:always)
          expect(api_class.explorer_config.path).to eq('/explorer')
        end
      end
    end
  end

  describe '.export' do
    it 'registers the export' do
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

  describe '.locales' do
    it 'returns the locales' do
      api_class = Apiwork::API.define '/unit/base-locales' do
        locales :en, :sv, :it
      end

      expect(api_class.locales).to eq(%i[en sv it])
    end

    it 'returns empty array when not set' do
      api_class = Apiwork::API.define('/unit/base-locales-default') {}

      expect(api_class.locales).to eq([])
    end

    it 'raises ConfigurationError for non-symbol' do
      expect do
        Apiwork::API.define '/unit/base-locales-invalid' do
          locales 'en'
        end
      end.to raise_error(Apiwork::ConfigurationError, /locales must be symbols/)
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

  describe '.resource' do
    it 'defines a singular resource' do
      api_class = Apiwork::API.define '/unit/base-resource' do
        resource :profile
      end

      expect(api_class.root_resource.resources).to have_key(:profile)
      expect(api_class.root_resource.resources[:profile].singular).to be(true)
    end
  end

  describe '.resources' do
    it 'defines a resource' do
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

  describe '.with_options' do
    it 'forwards all options' do
      api_class = Apiwork::API.define '/unit/base-with-options' do
        with_options only: [:index, :show] do
          resources :invoices
        end
      end

      resource = api_class.root_resource.resources[:invoices]
      expect(resource.only).to eq([:index, :show])
    end
  end

  describe '.transform_key' do
    context 'when key_format is :keep' do
      it 'returns the key unchanged' do
        api_class = Apiwork::API.define('/unit/base-transform-key-keep') {}

        expect(api_class.transform_key(:created_at)).to eq('created_at')
      end
    end

    context 'when key_format is :camel' do
      it 'returns camelCase' do
        api_class = Apiwork::API.define '/unit/base-transform-key-camel' do
          key_format :camel
        end

        expect(api_class.transform_key(:created_at)).to eq('createdAt')
      end
    end

    context 'when key_format is :pascal' do
      it 'returns PascalCase' do
        api_class = Apiwork::API.define '/unit/base-transform-key-pascal' do
          key_format :pascal
        end

        expect(api_class.transform_key(:created_at)).to eq('CreatedAt')
      end
    end

    context 'when key_format is :kebab' do
      it 'returns kebab-case' do
        api_class = Apiwork::API.define '/unit/base-transform-key-kebab' do
          key_format :kebab
        end

        expect(api_class.transform_key(:created_at)).to eq('created-at')
      end
    end

    context 'when key_format is :underscore' do
      it 'returns underscore' do
        api_class = Apiwork::API.define '/unit/base-transform-key-underscore' do
          key_format :underscore
        end

        expect(api_class.transform_key(:created_at)).to eq('created_at')
      end
    end

    context 'when key is ALL-CAPS' do
      it 'preserves the key' do
        api_class = Apiwork::API.define '/unit/base-transform-key-allcaps' do
          key_format :camel
        end

        expect(api_class.transform_key(:OP)).to eq('OP')
      end
    end
  end

  describe '.prepare_error_response' do
    let(:error_body) do
      {
        issues: [
          {
            code: :too_small,
            detail: 'Too small',
            meta: { gt: 0 },
            path: %w[invoice hourly_rate_cents],
            pointer: '/invoice/hourly_rate_cents',
          },
        ],
        layer: :domain,
      }
    end

    context 'when key_format is :keep' do
      it 'returns the body unchanged' do
        api_class = Apiwork::API.define('/unit/base-prepare-error-keep') {}
        response = Apiwork::Response.new(body: error_body)

        result = api_class.prepare_error_response(response)

        issue = result.body[:issues].first
        expect(issue[:path]).to eq(%w[invoice hourly_rate_cents])
        expect(issue[:pointer]).to eq('/invoice/hourly_rate_cents')
      end
    end

    context 'when key_format is :camel' do
      it 'transforms object keys' do
        api_class = Apiwork::API.define '/unit/base-prepare-error-camel-keys' do
          key_format :camel
        end
        response = Apiwork::Response.new(body: error_body)

        result = api_class.prepare_error_response(response)

        expect(result.body).to have_key(:issues)
        expect(result.body).to have_key(:layer)
      end

      it 'transforms issue path segments' do
        api_class = Apiwork::API.define '/unit/base-prepare-error-camel-path' do
          key_format :camel
        end
        response = Apiwork::Response.new(body: error_body)

        result = api_class.prepare_error_response(response)

        issue = result.body[:issues].first
        expect(issue[:path]).to eq(%w[invoice hourlyRateCents])
      end

      it 'transforms issue pointer segments' do
        api_class = Apiwork::API.define '/unit/base-prepare-error-camel-pointer' do
          key_format :camel
        end
        response = Apiwork::Response.new(body: error_body)

        result = api_class.prepare_error_response(response)

        issue = result.body[:issues].first
        expect(issue[:pointer]).to eq('/invoice/hourlyRateCents')
      end

      it 'preserves integer path segments' do
        api_class = Apiwork::API.define '/unit/base-prepare-error-camel-array' do
          key_format :camel
        end
        nested_body = {
          issues: [
            {
              code: :required,
              detail: 'Required',
              meta: {},
              path: ['invoice', 'line_items', 0, 'unit_price'],
              pointer: '/invoice/line_items/0/unit_price',
            },
          ],
          layer: :contract,
        }
        response = Apiwork::Response.new(body: nested_body)

        result = api_class.prepare_error_response(response)

        issue = result.body[:issues].first
        expect(issue[:path]).to eq(['invoice', 'lineItems', 0, 'unitPrice'])
        expect(issue[:pointer]).to eq('/invoice/lineItems/0/unitPrice')
      end
    end

    context 'when key_format is :kebab' do
      it 'transforms issue path segments' do
        api_class = Apiwork::API.define '/unit/base-prepare-error-kebab-path' do
          key_format :kebab
        end
        response = Apiwork::Response.new(body: error_body)

        result = api_class.prepare_error_response(response)

        issue = result.body[:issues].first
        expect(issue[:path]).to eq(%w[invoice hourly-rate-cents])
        expect(issue[:pointer]).to eq('/invoice/hourly-rate-cents')
      end
    end
  end
end
