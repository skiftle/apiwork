# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract types', type: :integration do
  describe 'Object types' do
    it 'defines a reusable custom object type' do
      api = Apiwork::API.define '/integration/types-object' do
        object :address do
          string :street
          string :city
          string :zip
        end
      end

      expect(api.type_registry.key?(:address)).to be(true)
      expect(api.type?(:address)).to be(true)
    end

    it 'supports nested object types' do
      api = Apiwork::API.define '/integration/types-nested' do
        object :line_item do
          string :description
          integer :quantity
          object :price do
            decimal :amount
            string :currency
          end
        end
      end

      expect(api.type_registry.key?(:line_item)).to be(true)
    end
  end

  describe 'Enum types' do
    it 'defines a reusable enumeration type' do
      api = Apiwork::API.define '/integration/types-enum' do
        enum :invoice_status, values: %i[draft sent paid overdue void]
      end

      expect(api.enum_registry.key?(:invoice_status)).to be(true)
      expect(api.enum_values(:invoice_status)).to eq(%i[draft sent paid overdue void])
    end

    it 'supports enum with description' do
      api = Apiwork::API.define '/integration/types-enum-desc' do
        enum :payment_method,
             description: 'Accepted payment methods',
             values: %i[credit_card bank_transfer]
      end

      expect(api.enum_registry[:payment_method].description).to eq('Accepted payment methods')
    end

    it 'supports deprecated enums' do
      api = Apiwork::API.define '/integration/types-enum-deprecated' do
        enum :old_status, deprecated: true, values: %i[on off]
      end

      expect(api.enum_registry[:old_status].deprecated?).to be(true)
    end
  end

  describe 'Union types' do
    it 'defines a discriminated union type' do
      api = Apiwork::API.define '/integration/types-union' do
        union :notification, discriminator: :type do
          variant tag: :email do
            object do
              string :address
              string :subject
            end
          end

          variant tag: :sms do
            object do
              string :phone_number
            end
          end
        end
      end

      expect(api.type_registry.key?(:notification)).to be(true)

      definition = api.type_registry[:notification]
      expect(definition.discriminator).to eq(:type)
    end

    it 'includes union in introspection' do
      api = Apiwork::API.define '/integration/types-union-introspect' do
        union :payment, discriminator: :method do
          variant tag: :card do
            object do
              string :card_number
            end
          end

          variant tag: :bank do
            object do
              string :account_number
            end
          end
        end
      end

      introspection = api.introspect
      expect(introspection.types).to have_key(:payment)
    end
  end

  describe 'Fragment types' do
    it 'defines a reusable fragment for composition' do
      api = Apiwork::API.define '/integration/types-fragment' do
        fragment :timestamps do
          datetime :created_at
          datetime :updated_at
        end

        object :invoice do
          merge :timestamps
          string :number
        end
      end

      expect(api.type_registry.key?(:timestamps)).to be(true)
      expect(api.type_registry[:timestamps].fragment?).to be(true)
    end
  end

  describe 'Type scoping' do
    it 'scopes types to a contract' do
      api = Apiwork::API.define '/integration/types-scoped' do
        enum :status, values: %i[active inactive]

        resources :invoices
      end

      expect(api.enum_registry.key?(:status)).to be(true)
      expect(api.enum_values(:status)).to eq(%i[active inactive])
    end
  end

  describe 'Existing V1 API types' do
    let(:api_class) { Apiwork::API.find!('/api/v1') }

    it 'has API-level object types defined' do
      expect(api_class.type_registry.key?(:error_detail)).to be(true)
      expect(api_class.type_registry.key?(:pagination_params)).to be(true)
    end

    it 'has API-level enums defined' do
      expect(api_class.enum_registry.key?(:sort_direction)).to be(true)
      expect(api_class.enum_values(:sort_direction)).to eq(%i[asc desc])
    end

    it 'exposes types via type registry' do
      expect(api_class.type?(:error_detail)).to be(true)
      expect(api_class.enum?(:sort_direction)).to be(true)
    end
  end

  describe 'Type checking methods' do
    it 'returns true for existing types and false for missing' do
      api = Apiwork::API.define '/integration/types-check' do
        object :invoice do
          string :number
        end

        enum :status, values: %i[draft sent]
      end

      expect(api.type?(:invoice)).to be(true)
      expect(api.type?(:nonexistent)).to be(false)
      expect(api.enum?(:status)).to be(true)
      expect(api.enum?(:nonexistent)).to be(false)
    end
  end
end
