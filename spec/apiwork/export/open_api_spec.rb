# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::OpenAPI do
  describe '#generate' do
    before do
      Apiwork::API.define '/unit/openapi-generate' do
        export :openapi

        info do
          title 'Billing API'
          version '2.0.0'
          summary 'Invoice management'
          description 'API for managing invoices and payments'
          terms_of_service 'https://acme.com/terms'

          contact do
            name 'Anna Svensson'
            email 'billing@acme.com'
            url 'https://acme.com'
          end

          license do
            name 'MIT'
            url 'https://opensource.org/licenses/MIT'
          end

          server do
            url 'https://api.acme.com'
            description 'Production'
          end
        end

        enum :invoice_status, values: %w[draft sent paid]

        object :invoice do
          string :number
          integer :count
          number :amount
          decimal :price
          boolean :active
          date :due_on
          datetime :created_at
          time :start_time
          uuid :external_id
          binary :data
          string :notes, nullable: true
          string :status, enum: :invoice_status
          string :description_field, description: 'Invoice description'
          string :example_field, example: 'INV-001'
          string :old_field, deprecated: true
          string :email, format: :email
          integer :min_field, max: 100, min: 0
        end

        object :receipt do
          string :number
        end

        object :payment do
          integer :id
          reference :invoice
          reference :receipt, nullable: true
          string :method
        end

        object :item do
          string :name
          array :tags do
            string
          end
        end

        object :base_record do
          integer :id
        end

        object :extended_record do
          extends :base_record
          string :name
        end

        object :simple_record do
          extends :base_record
        end

        union :mixed_type do
          variant do
            string
          end
          variant do
            integer
          end
        end

        union :tagged_variant, discriminator: :kind do
          variant tag: 'invoice' do
            reference :invoice
          end
          variant tag: 'payment' do
            reference :payment
          end
        end

        resources :invoices do
          member do
            patch :send_invoice
          end
          collection do
            get :search
          end
          resources :items
        end

        resources :payments
      end

      allow(Apiwork::Export::SurfaceResolver).to receive(:resolve) do |api|
        Struct.new(:types, :enums).new(api.types, api.enums)
      end
    end

    let(:generator) { described_class.new('/unit/openapi-generate') }
    let(:spec) { generator.generate }
    let(:schemas) { spec[:components][:schemas] }

    it 'includes openapi version' do
      expect(spec[:openapi]).to eq('3.1.0')
    end

    it 'orders top-level keys according to specification' do
      keys = spec.keys

      expect(keys).to eq(%i[openapi info servers paths components])
    end

    context 'with primitive type fields' do
      it 'maps string to type string' do
        expect(schemas['invoice'][:properties]['number'][:type]).to eq('string')
      end

      it 'maps integer to type integer' do
        expect(schemas['invoice'][:properties]['count'][:type]).to eq('integer')
      end

      it 'maps number to type number with double format' do
        property = schemas['invoice'][:properties]['amount']

        expect(property[:type]).to eq('number')
        expect(property[:format]).to eq('double')
      end

      it 'maps decimal to type number' do
        expect(schemas['invoice'][:properties]['price'][:type]).to eq('number')
      end

      it 'maps boolean to type boolean' do
        expect(schemas['invoice'][:properties]['active'][:type]).to eq('boolean')
      end

      it 'maps date to string with date format' do
        property = schemas['invoice'][:properties]['due_on']

        expect(property[:type]).to eq('string')
        expect(property[:format]).to eq('date')
      end

      it 'maps datetime to string with date-time format' do
        property = schemas['invoice'][:properties]['created_at']

        expect(property[:type]).to eq('string')
        expect(property[:format]).to eq('date-time')
      end

      it 'maps time to string with time format' do
        property = schemas['invoice'][:properties]['start_time']

        expect(property[:type]).to eq('string')
        expect(property[:format]).to eq('time')
      end

      it 'maps uuid to string with uuid format' do
        property = schemas['invoice'][:properties]['external_id']

        expect(property[:type]).to eq('string')
        expect(property[:format]).to eq('uuid')
      end

      it 'maps binary to string with byte format' do
        property = schemas['invoice'][:properties]['data']

        expect(property[:type]).to eq('string')
        expect(property[:format]).to eq('byte')
      end
    end

    context 'with nullable fields' do
      it 'adds null to type array for nullable primitive' do
        property = schemas['invoice'][:properties]['notes']

        expect(property[:type]).to eq(%w[string null])
      end
    end

    context 'with enum fields' do
      it 'maps enum reference to enum values' do
        property = schemas['invoice'][:properties]['status']

        expect(property[:enum]).to contain_exactly('draft', 'paid', 'sent')
        expect(property[:type]).to eq('string')
      end
    end

    context 'with field modifiers' do
      it 'includes description' do
        expect(schemas['invoice'][:properties]['description_field'][:description]).to eq('Invoice description')
      end

      it 'includes example' do
        expect(schemas['invoice'][:properties]['example_field'][:example]).to eq('INV-001')
      end

      it 'includes deprecated flag' do
        expect(schemas['invoice'][:properties]['old_field'][:deprecated]).to be(true)
      end

      it 'includes format annotation' do
        expect(schemas['invoice'][:properties]['email'][:format]).to eq('email')
      end

      it 'includes min and max constraints' do
        property = schemas['invoice'][:properties]['min_field']

        expect(property[:minimum]).to eq(0)
        expect(property[:maximum]).to eq(100)
      end
    end

    context 'with object types' do
      it 'generates properties and required fields' do
        invoice_schema = schemas['invoice']

        expect(invoice_schema[:type]).to eq('object')
        expect(invoice_schema[:properties]).to be_a(Hash)
        expect(invoice_schema[:required]).to include('number', 'count')
      end

      it 'lists non-optional fields in required array' do
        invoice_schema = schemas['invoice']

        expect(invoice_schema[:required]).to be_an(Array)
        expect(invoice_schema[:required]).to include('number', 'count', 'active')
      end
    end

    context 'with reference fields' do
      it 'generates $ref for reference fields' do
        expect(schemas['payment'][:properties]['invoice']).to eq({ '$ref': '#/components/schemas/invoice' })
      end
    end

    context 'with nullable references' do
      it 'generates oneOf with $ref and null type' do
        receipt_property = schemas['payment'][:properties]['receipt']

        expect(receipt_property[:oneOf]).to be_an(Array)
        expect(receipt_property[:oneOf]).to include({ '$ref': '#/components/schemas/receipt' })
        expect(receipt_property[:oneOf]).to include({ type: 'null' })
      end
    end

    context 'with extends' do
      it 'generates allOf for extends with properties' do
        extended_schema = schemas['extended_record']

        expect(extended_schema[:allOf]).to be_an(Array)
        expect(extended_schema[:allOf].first).to eq({ '$ref': '#/components/schemas/base_record' })
      end

      it 'includes object schema in allOf' do
        extended_schema = schemas['extended_record']
        object_part = extended_schema[:allOf].last

        expect(object_part[:type]).to eq('object')
        expect(object_part[:properties]).to have_key('name')
      end

      it 'generates $ref directly for single extends without properties' do
        simple_schema = schemas['simple_record']

        expect(simple_schema).to eq({ '$ref': '#/components/schemas/base_record' })
      end
    end

    context 'with union types' do
      it 'generates oneOf for simple union' do
        mixed_schema = schemas['mixed_type']

        expect(mixed_schema[:oneOf]).to be_an(Array)
        expect(mixed_schema[:oneOf].size).to eq(2)
      end

      it 'includes correct types in oneOf' do
        mixed_schema = schemas['mixed_type']
        types = mixed_schema[:oneOf].map { |variant| variant[:type] }

        expect(types).to contain_exactly('string', 'integer')
      end
    end

    context 'with discriminated unions' do
      it 'generates discriminator with mapping' do
        tagged_schema = schemas['tagged_variant']

        expect(tagged_schema[:discriminator]).to be_a(Hash)
        expect(tagged_schema[:discriminator][:propertyName]).to eq('kind')
        expect(tagged_schema[:discriminator][:mapping]).to be_a(Hash)
      end

      it 'generates const with type for variant discriminator' do
        tagged_schema = schemas['tagged_variant']
        first_variant = tagged_schema[:oneOf].first

        expect(first_variant[:allOf]).to be_an(Array)
        discriminator_schema = first_variant[:allOf].last
        expect(discriminator_schema[:properties]['kind'][:const]).to eq('invoice')
        expect(discriminator_schema[:properties]['kind'][:type]).to eq('string')
      end

      it 'includes required discriminator in variant allOf' do
        tagged_schema = schemas['tagged_variant']
        first_variant = tagged_schema[:oneOf].first
        discriminator_part = first_variant[:allOf].last

        expect(discriminator_part[:required]).to eq(['kind'])
        expect(discriminator_part[:type]).to eq('object')
      end

      it 'generates mapping for reference variants' do
        tagged_schema = schemas['tagged_variant']
        mapping = tagged_schema[:discriminator][:mapping]

        expect(mapping).to include('invoice' => '#/components/schemas/invoice')
        expect(mapping).to include('payment' => '#/components/schemas/payment')
      end
    end

    context 'with array fields' do
      it 'generates typed array with items' do
        tags_property = schemas['item'][:properties]['tags']

        expect(tags_property[:type]).to eq('array')
        expect(tags_property[:items][:type]).to eq('string')
      end
    end

    context 'with info block' do
      it 'includes title and version' do
        expect(spec[:info][:title]).to eq('Billing API')
        expect(spec[:info][:version]).to eq('2.0.0')
      end

      it 'includes contact information' do
        contact = spec[:info][:contact]

        expect(contact[:name]).to eq('Anna Svensson')
        expect(contact[:email]).to eq('billing@acme.com')
        expect(contact[:url]).to eq('https://acme.com')
      end

      it 'includes license information' do
        license = spec[:info][:license]

        expect(license[:name]).to eq('MIT')
        expect(license[:url]).to eq('https://opensource.org/licenses/MIT')
      end

      it 'includes servers' do
        expect(spec[:servers]).to be_an(Array)
        expect(spec[:servers].first[:url]).to eq('https://api.acme.com')
      end

      it 'includes summary and description' do
        expect(spec[:info][:summary]).to eq('Invoice management')
        expect(spec[:info][:description]).to eq('API for managing invoices and payments')
      end

      it 'includes terms of service' do
        expect(spec[:info][:termsOfService]).to eq('https://acme.com/terms')
      end
    end

    context 'with operations' do
      it 'generates operationId' do
        index_operation = spec[:paths]['/invoices']['get']

        expect(index_operation[:operationId]).to eq('invoices_index')
      end
    end

    context 'with path parameters' do
      it 'extracts path parameters from path' do
        show_operation = spec[:paths]['/invoices/{id}']['get']
        id_param = show_operation[:parameters].find { |param| param[:name] == 'id' }

        expect(id_param[:in]).to eq('path')
        expect(id_param[:required]).to be(true)
        expect(id_param[:schema]).to eq({ type: 'string' })
      end
    end

    context 'with nested resources' do
      it 'generates paths for nested resources' do
        nested_paths = spec[:paths].keys.select { |path| path.include?('/items') }

        expect(nested_paths).not_to be_empty
      end
    end
  end
end
