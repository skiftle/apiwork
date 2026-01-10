# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Type merging' do
  describe 'API-level merging' do
    describe 'object merging' do
      it 'merges params from multiple declarations' do
        api_class = Apiwork::API.define '/api/test' do
          object :address do
            param :street, type: :string
          end

          object :address do
            param :city, type: :string
          end
        end

        definition = api_class.type_registry[:address]

        expect(definition.params.keys).to contain_exactly(:street, :city)
      end

      it 'uses last description (last wins)' do
        api_class = Apiwork::API.define '/api/test' do
          object :address, description: 'First' do
            param :street, type: :string
          end

          object :address, description: 'Second'
        end

        definition = api_class.type_registry[:address]

        expect(definition.description).to eq('Second')
      end

      it 'keeps first description if second is nil' do
        api_class = Apiwork::API.define '/api/test' do
          object :address, description: 'First' do
            param :street, type: :string
          end

          object :address do
            param :city, type: :string
          end
        end

        definition = api_class.type_registry[:address]

        expect(definition.description).to eq('First')
      end

      it 'extends existing params with new options' do
        api_class = Apiwork::API.define '/api/test' do
          object :user do
            param :name, type: :string
          end

          object :user do
            param :name, description: 'Full name'
            param :email, type: :string
          end
        end

        definition = api_class.type_registry[:user]

        expect(definition.params[:name][:type]).to eq(:string)
        expect(definition.params[:name][:description]).to eq('Full name')
        expect(definition.params[:email]).to be_present
      end

      it 'merges all metadata fields (last wins)' do
        api_class = Apiwork::API.define '/api/test' do
          object :address,
                 deprecated: false,
                 description: 'First desc',
                 example: { old: true },
                 format: 'old-format' do
            param :street, type: :string
          end

          object :address,
                 deprecated: true,
                 example: { new: true }
        end

        definition = api_class.type_registry[:address]

        expect(definition.deprecated?).to be(true)
        expect(definition.description).to eq('First desc')
        expect(definition.example).to eq({ new: true })
        expect(definition.format).to eq('old-format')
      end

      it 'preserves kind and raises on mismatch' do
        expect do
          Apiwork::API.define '/api/test' do
            object :thing do
              param :field, type: :string
            end

            union :thing, discriminator: :type do
              variant tag: 'text', type: :string
            end
          end
        end.to raise_error(Apiwork::ConfigurationError, /Cannot redefine :thing/)
      end
    end

    describe 'union merging' do
      it 'merges variants from multiple declarations' do
        api_class = Apiwork::API.define '/api/test' do
          union :payment, discriminator: :type do
            variant tag: 'card', type: :object do
              param :last_four, type: :string
            end
          end

          union :payment, discriminator: :type do
            variant tag: 'bank', type: :object do
              param :account, type: :string
            end
          end
        end

        definition = api_class.type_registry[:payment]
        tags = definition.variants.map { |variant| variant[:tag] }

        expect(tags).to contain_exactly('card', 'bank')
      end

      it 'merges same tag variant instead of duplicating' do
        api_class = Apiwork::API.define '/api/test' do
          union :payment, discriminator: :type do
            variant tag: 'card', type: :card_details
          end

          union :payment, discriminator: :type do
            variant partial: true, tag: 'card', type: :card_details
          end
        end

        definition = api_class.type_registry[:payment]

        expect(definition.variants.count).to eq(1)
        expect(definition.variants.first[:type]).to eq(:card_details)
        expect(definition.variants.first[:partial]).to be(true)
      end
    end

    describe 'enum merging' do
      it 'replaces values entirely' do
        api_class = Apiwork::API.define '/api/test' do
          enum :status, values: %w[pending active]
          enum :status, values: %w[pending active archived]
        end

        values = api_class.enum_registry.values(:status)

        expect(values).to eq(%w[pending active archived])
      end

      it 'merges metadata (last wins)' do
        api_class = Apiwork::API.define '/api/test' do
          enum :status, values: %w[active inactive]
          enum :status, description: 'Account status'
        end

        definition = api_class.enum_registry[:status]

        expect(definition.values).to eq(%w[active inactive])
        expect(definition.description).to eq('Account status')
      end
    end
  end

  describe 'contract-scoped merging' do
    describe 'object merging' do
      it 'merges params within contract scope' do
        contract_class = create_test_contract do
          identifier :invoice

          object :address do
            param :street, type: :string
          end

          object :address do
            param :city, type: :string
          end
        end

        definition = contract_class.api_class.type_registry[:invoice_address]

        expect(definition.params.keys).to contain_exactly(:street, :city)
      end

      it 'extends existing param with new options' do
        contract_class = create_test_contract do
          identifier :customer

          object :profile do
            param :name, type: :string
          end

          object :profile do
            param :name, description: 'Customer name'
          end
        end

        definition = contract_class.api_class.type_registry[:customer_profile]

        expect(definition.params[:name][:type]).to eq(:string)
        expect(definition.params[:name][:description]).to eq('Customer name')
      end
    end

    describe 'union merging' do
      it 'merges variants within contract scope' do
        contract_class = create_test_contract do
          identifier :billing

          union :payment, discriminator: :type do
            variant tag: 'card', type: :string
          end

          union :payment, discriminator: :type do
            variant tag: 'bank', type: :string
          end
        end

        definition = contract_class.api_class.type_registry[:billing_payment]
        tags = definition.variants.map { |variant| variant[:tag] }

        expect(tags).to contain_exactly('card', 'bank')
      end
    end

    describe 'enum merging' do
      it 'merges metadata within contract scope' do
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
end
