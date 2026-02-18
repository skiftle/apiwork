# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Type merging in exports', type: :integration do
  describe 'API-level object merging' do
    it 'merges params from multiple declarations' do
      api_class = Apiwork::API.define '/integration/type-merging-object' do
        object :address do
          string :street
        end

        object :address do
          string :city
        end
      end

      definition = api_class.type_registry[:address]

      expect(definition.params.keys).to contain_exactly(:street, :city)
    end

    it 'uses last description when both provided' do
      api_class = Apiwork::API.define '/integration/type-merging-description-last-wins' do
        object :address, description: 'First' do
          string :street
        end
        object :address, description: 'Second'
      end

      expect(api_class.type_registry[:address].description).to eq('Second')
    end

    it 'keeps first description when second is nil' do
      api_class = Apiwork::API.define '/integration/type-merging-description-kept' do
        object :address, description: 'First' do
          string :street
        end
        object :address do
          string :city
        end
      end

      expect(api_class.type_registry[:address].description).to eq('First')
    end

    it 'extends existing params with new options' do
      api_class = Apiwork::API.define '/integration/type-merging-param-extension' do
        object :customer do
          string :name
        end

        object :customer do
          param :name, description: 'Full name'
          string :email
        end
      end

      definition = api_class.type_registry[:customer]

      expect(definition.params[:name][:type]).to eq(:string)
      expect(definition.params[:name][:description]).to eq('Full name')
      expect(definition.params[:email][:type]).to eq(:string)
    end

    it 'raises on kind mismatch' do
      expect do
        Apiwork::API.define '/integration/type-merging-kind-mismatch' do
          object :payment do
            string :field
          end

          union :payment, discriminator: :type do
            variant tag: 'text' do
              string
            end
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Cannot redefine :payment/)
    end
  end

  describe 'API-level union merging' do
    it 'merges variants from multiple declarations' do
      api_class = Apiwork::API.define '/integration/type-merging-union-variants' do
        union :payment, discriminator: :type do
          variant tag: 'card' do
            object do
              string :last_four
            end
          end
        end

        union :payment, discriminator: :type do
          variant tag: 'bank' do
            object do
              string :account
            end
          end
        end
      end

      definition = api_class.type_registry[:payment]
      tags = definition.variants.map { |variant| variant[:tag] }

      expect(tags).to contain_exactly('card', 'bank')
    end
  end

  describe 'API-level enum merging' do
    it 'replaces values with last declaration' do
      api_class = Apiwork::API.define '/integration/type-merging-enum-values' do
        enum :status, values: %w[pending active]
        enum :status, values: %w[pending active archived]
      end

      expect(api_class.enum_registry.values(:status)).to eq(%w[pending active archived])
    end

    it 'merges metadata with last-wins strategy' do
      api_class = Apiwork::API.define '/integration/type-merging-enum-metadata' do
        enum :status, values: %w[active inactive]
        enum :status, description: 'Account status'
      end

      definition = api_class.enum_registry[:status]

      expect(definition.values).to eq(%w[active inactive])
      expect(definition.description).to eq('Account status')
    end
  end

  describe 'Merge with symbols' do
    it 'inlines params from merged type in introspection' do
      api_class = Apiwork::API.define '/integration/type-merging-merge-symbol' do
        object :base do
          string :name
          string :email
        end

        object :admin do
          merge :base
          boolean :superuser
        end
      end

      introspection = Apiwork::Introspection::Dump::API.new(api_class).to_h
      admin_type = introspection[:types][:admin]

      expect(admin_type[:shape].keys).to contain_exactly(:email, :name, :superuser)
    end

    it 'allows own params to override merged params' do
      api_class = Apiwork::API.define '/integration/type-merging-merge-override' do
        object :base do
          string :name
        end

        object :child do
          merge :base
          string :name, description: 'Overridden'
        end
      end

      introspection = Apiwork::Introspection::Dump::API.new(api_class).to_h
      child_type = introspection[:types][:child]

      expect(child_type[:shape][:name][:description]).to eq('Overridden')
    end
  end

  describe 'Contract-scoped merging' do
    it 'merges params within contract scope' do
      contract_class = create_test_contract do
        identifier :invoice

        object :address do
          string :street
        end

        object :address do
          string :city
        end
      end

      definition = contract_class.api_class.type_registry[:invoice_address]

      expect(definition.params.keys).to contain_exactly(:street, :city)
    end

    it 'merges enum metadata within contract scope' do
      contract_class = create_test_contract do
        identifier :order
        enum :status, values: %w[draft sent]
        enum :status, description: 'Order status'
      end

      definition = contract_class.api_class.enum_registry[:order_status]

      expect(definition.values).to eq(%w[draft sent])
      expect(definition.description).to eq('Order status')
    end
  end
end
