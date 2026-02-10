# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Type merging' do
  describe 'API-level merging' do
    describe 'object merging' do
      it 'merges params from multiple declarations' do
        api_class = Apiwork::API.define '/api/test' do
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

      it 'uses last description (last wins)' do
        api_class = Apiwork::API.define '/api/test' do
          object :address, description: 'First' do
            string :street
          end

          object :address, description: 'Second'
        end

        definition = api_class.type_registry[:address]

        expect(definition.description).to eq('Second')
      end

      it 'keeps first description if second is nil' do
        api_class = Apiwork::API.define '/api/test' do
          object :address, description: 'First' do
            string :street
          end

          object :address do
            string :city
          end
        end

        definition = api_class.type_registry[:address]

        expect(definition.description).to eq('First')
      end

      it 'extends existing params with new options' do
        api_class = Apiwork::API.define '/api/test' do
          object :user do
            string :name
          end

          object :user do
            param :name, description: 'Full name'
            string :email
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
                 example: { old: true } do
            string :street
          end

          object :address,
                 deprecated: true,
                 example: { new: true }
        end

        definition = api_class.type_registry[:address]

        expect(definition.deprecated?).to be(true)
        expect(definition.description).to eq('First desc')
        expect(definition.example).to eq({ new: true })
      end

      it 'preserves kind and raises on mismatch' do
        expect do
          Apiwork::API.define '/api/test' do
            object :thing do
              string :field
            end

            union :thing, discriminator: :type do
              variant tag: 'text' do
                string
              end
            end
          end
        end.to raise_error(Apiwork::ConfigurationError, /Cannot redefine :thing/)
      end
    end

    describe 'union merging' do
      it 'merges variants from multiple declarations' do
        api_class = Apiwork::API.define '/api/test' do
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

      it 'merges same tag variant instead of duplicating' do
        api_class = Apiwork::API.define '/api/test' do
          union :payment, discriminator: :type do
            variant tag: 'card' do
              reference :card_details
            end
          end

          union :payment, discriminator: :type do
            variant partial: true, tag: 'card' do
              reference :card_details
            end
          end
        end

        definition = api_class.type_registry[:payment]

        expect(definition.variants.count).to eq(1)
        expect(definition.variants.first[:type]).to eq(:card_details)
        expect(definition.variants.first[:partial]).to be(true)
      end

      it 'merges variant shape params instead of replacing' do
        api_class = Apiwork::API.define '/api/test' do
          union :payment, discriminator: :type do
            variant tag: 'card' do
              object do
                string :number
              end
            end
          end

          union :payment, discriminator: :type do
            variant tag: 'card' do
              object do
                string :cvv
              end
            end
          end
        end

        definition = api_class.type_registry[:payment]
        card_variant = definition.variants.find { |variant| variant[:tag] == 'card' }

        expect(card_variant[:shape].params.keys).to contain_exactly(:number, :cvv)
      end

      it 'merges variant shape param options' do
        api_class = Apiwork::API.define '/api/test' do
          union :payment, discriminator: :type do
            variant tag: 'card' do
              object do
                string :number
              end
            end
          end

          union :payment, discriminator: :type do
            variant tag: 'card' do
              object do
                param :number, description: 'Card number'
              end
            end
          end
        end

        definition = api_class.type_registry[:payment]
        card_variant = definition.variants.find { |variant| variant[:tag] == 'card' }

        expect(card_variant[:shape].params[:number][:type]).to eq(:string)
        expect(card_variant[:shape].params[:number][:description]).to eq('Card number')
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

  describe 'merge! with symbols' do
    it 'inlines params from merged type in introspection' do
      api_class = Apiwork::API.define '/api/test' do
        object :base do
          string :name
          string :email
        end

        object :admin do
          merge! :base
          boolean :superuser
        end
      end

      introspection = Apiwork::Introspection::Dump::API.new(api_class).to_h
      admin_type = introspection[:types][:admin]

      expect(admin_type[:shape].keys).to contain_exactly(:email, :name, :superuser)
    end

    it 'allows own params to override merged params' do
      api_class = Apiwork::API.define '/api/test' do
        object :base do
          string :name
        end

        object :child do
          merge! :base
          string :name, description: 'Overridden'
        end
      end

      introspection = Apiwork::Introspection::Dump::API.new(api_class).to_h
      child_type = introspection[:types][:child]

      expect(child_type[:shape][:name][:description]).to eq('Overridden')
    end

    it 'supports multiple merged types' do
      api_class = Apiwork::API.define '/api/test' do
        object :contactable do
          string :email
          string :phone
        end

        object :timestamped do
          datetime :created_at
          datetime :updated_at
        end

        object :customer do
          merge! :contactable
          merge! :timestamped
          string :name
        end
      end

      introspection = Apiwork::Introspection::Dump::API.new(api_class).to_h
      customer_type = introspection[:types][:customer]

      expect(customer_type[:shape].keys).to contain_exactly(
        :created_at, :email, :name, :phone, :updated_at
      )
    end

    it 'does not show merge reference in output (unlike extends)' do
      api_class = Apiwork::API.define '/api/test' do
        object :base do
          string :name
        end

        object :child do
          merge! :base
        end
      end

      introspection = Apiwork::Introspection::Dump::API.new(api_class).to_h
      child_type = introspection[:types][:child]

      expect(child_type[:extends]).to be_empty
      expect(child_type[:shape].keys).to eq([:name])
    end
  end

  describe 'contract-scoped merging' do
    describe 'object merging' do
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

      it 'extends existing param with new options' do
        contract_class = create_test_contract do
          identifier :customer

          object :profile do
            string :name
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
            variant tag: 'card' do
              string
            end
          end

          union :payment, discriminator: :type do
            variant tag: 'bank' do
              string
            end
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
