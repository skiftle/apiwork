# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Object do
  describe '#array' do
    context 'with defaults' do
      it 'defines an array param' do
        object = described_class.new
        object.array(:tags) { string }

        expect(object.params[:tags][:type]).to eq(:array)
        expect(object.params[:tags][:deprecated]).to be(false)
        expect(object.params[:tags][:nullable]).to be(false)
        expect(object.params[:tags][:optional]).to be(false)
        expect(object.params[:tags][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.array(
          :tags,
          as: :labels,
          default: [],
          deprecated: true,
          description: 'The tags',
          nullable: true,
          optional: true,
          required: false,
        ) { string }

        param = object.params[:tags]
        expect(param[:as]).to eq(:labels)
        expect(param[:default]).to eq([])
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The tags')
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#array?' do
    context 'with defaults' do
      it 'defines an optional array param' do
        object = described_class.new
        object.array?(:tags) { string }

        expect(object.params[:tags][:type]).to eq(:array)
        expect(object.params[:tags][:optional]).to be(true)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.array?(
          :tags,
          as: :labels,
          default: [],
          deprecated: true,
          description: 'The tags',
          nullable: true,
          required: false,
        ) { string }

        param = object.params[:tags]
        expect(param[:as]).to eq(:labels)
        expect(param[:default]).to eq([])
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The tags')
        expect(param[:nullable]).to be(true)
      end
    end
  end

  describe '#binary' do
    context 'with defaults' do
      it 'defines a binary param' do
        object = described_class.new
        object.binary(:content)

        expect(object.params[:content][:type]).to eq(:binary)
        expect(object.params[:content][:deprecated]).to be(false)
        expect(object.params[:content][:nullable]).to be(false)
        expect(object.params[:content][:optional]).to be(false)
        expect(object.params[:content][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.binary(
          :content,
          as: :data,
          default: '',
          deprecated: true,
          description: 'The content',
          example: 'base64data',
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:content]
        expect(param[:as]).to eq(:data)
        expect(param[:default]).to eq('')
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The content')
        expect(param[:example]).to eq('base64data')
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#binary?' do
    context 'with defaults' do
      it 'defines an optional binary param' do
        object = described_class.new
        object.binary?(:attachment)

        expect(object.params[:attachment][:type]).to eq(:binary)
        expect(object.params[:attachment][:optional]).to be(true)
      end
    end
  end

  describe '#boolean' do
    context 'with defaults' do
      it 'defines a boolean param' do
        object = described_class.new
        object.boolean(:published)

        expect(object.params[:published][:type]).to eq(:boolean)
        expect(object.params[:published][:deprecated]).to be(false)
        expect(object.params[:published][:nullable]).to be(false)
        expect(object.params[:published][:optional]).to be(false)
        expect(object.params[:published][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.boolean(
          :published,
          as: :active,
          default: false,
          deprecated: true,
          description: 'Whether published',
          example: true,
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:published]
        expect(param[:as]).to eq(:active)
        expect(param[:default]).to be(false)
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('Whether published')
        expect(param[:example]).to be(true)
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#boolean?' do
    context 'with defaults' do
      it 'defines an optional boolean param' do
        object = described_class.new
        object.boolean?(:notify)

        expect(object.params[:notify][:type]).to eq(:boolean)
        expect(object.params[:notify][:optional]).to be(true)
      end
    end
  end

  describe '#date' do
    context 'with defaults' do
      it 'defines a date param' do
        object = described_class.new
        object.date(:due_date)

        expect(object.params[:due_date][:type]).to eq(:date)
        expect(object.params[:due_date][:deprecated]).to be(false)
        expect(object.params[:due_date][:nullable]).to be(false)
        expect(object.params[:due_date][:optional]).to be(false)
        expect(object.params[:due_date][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.date(
          :due_date,
          as: :deadline,
          default: '2025-01-01',
          deprecated: true,
          description: 'The due date',
          example: '2025-06-15',
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:due_date]
        expect(param[:as]).to eq(:deadline)
        expect(param[:default]).to eq('2025-01-01')
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The due date')
        expect(param[:example]).to eq('2025-06-15')
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#date?' do
    context 'with defaults' do
      it 'defines an optional date param' do
        object = described_class.new
        object.date?(:expires_on)

        expect(object.params[:expires_on][:type]).to eq(:date)
        expect(object.params[:expires_on][:optional]).to be(true)
      end
    end
  end

  describe '#datetime' do
    context 'with defaults' do
      it 'defines a datetime param' do
        object = described_class.new
        object.datetime(:created_at)

        expect(object.params[:created_at][:type]).to eq(:datetime)
        expect(object.params[:created_at][:deprecated]).to be(false)
        expect(object.params[:created_at][:nullable]).to be(false)
        expect(object.params[:created_at][:optional]).to be(false)
        expect(object.params[:created_at][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.datetime(
          :created_at,
          as: :timestamp,
          default: '2025-01-01T00:00:00Z',
          deprecated: true,
          description: 'The creation time',
          example: '2025-06-15T12:00:00Z',
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:created_at]
        expect(param[:as]).to eq(:timestamp)
        expect(param[:default]).to eq('2025-01-01T00:00:00Z')
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The creation time')
        expect(param[:example]).to eq('2025-06-15T12:00:00Z')
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#datetime?' do
    context 'with defaults' do
      it 'defines an optional datetime param' do
        object = described_class.new
        object.datetime?(:deleted_at)

        expect(object.params[:deleted_at][:type]).to eq(:datetime)
        expect(object.params[:deleted_at][:optional]).to be(true)
      end
    end
  end

  describe '#decimal' do
    context 'with defaults' do
      it 'defines a decimal param' do
        object = described_class.new
        object.decimal(:amount)

        expect(object.params[:amount][:type]).to eq(:decimal)
        expect(object.params[:amount][:deprecated]).to be(false)
        expect(object.params[:amount][:nullable]).to be(false)
        expect(object.params[:amount][:optional]).to be(false)
        expect(object.params[:amount][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.decimal(
          :amount,
          as: :total,
          default: 0.0,
          deprecated: true,
          description: 'The amount',
          example: 99.99,
          max: 10_000,
          min: 0,
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:amount]
        expect(param[:as]).to eq(:total)
        expect(param[:default]).to eq(0.0)
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The amount')
        expect(param[:example]).to eq(99.99)
        expect(param[:max]).to eq(10_000)
        expect(param[:min]).to eq(0)
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#decimal?' do
    context 'with defaults' do
      it 'defines an optional decimal param' do
        object = described_class.new
        object.decimal?(:tax_rate)

        expect(object.params[:tax_rate][:type]).to eq(:decimal)
        expect(object.params[:tax_rate][:optional]).to be(true)
      end
    end
  end

  describe '#extends' do
    it 'registers the type to extend' do
      object = described_class.new
      object.extends(:invoice)

      expect(object.extends).to eq([:invoice])
    end
  end

  describe '#integer' do
    context 'with defaults' do
      it 'defines an integer param' do
        object = described_class.new
        object.integer(:quantity)

        expect(object.params[:quantity][:type]).to eq(:integer)
        expect(object.params[:quantity][:deprecated]).to be(false)
        expect(object.params[:quantity][:nullable]).to be(false)
        expect(object.params[:quantity][:optional]).to be(false)
        expect(object.params[:quantity][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.integer(
          :quantity,
          as: :count,
          default: 1,
          deprecated: true,
          description: 'The quantity',
          enum: [1, 5, 10],
          example: 5,
          max: 100,
          min: 0,
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:quantity]
        expect(param[:as]).to eq(:count)
        expect(param[:default]).to eq(1)
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The quantity')
        expect(param[:enum]).to eq([1, 5, 10])
        expect(param[:example]).to eq(5)
        expect(param[:max]).to eq(100)
        expect(param[:min]).to eq(0)
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#integer?' do
    context 'with defaults' do
      it 'defines an optional integer param' do
        object = described_class.new
        object.integer?(:page)

        expect(object.params[:page][:type]).to eq(:integer)
        expect(object.params[:page][:optional]).to be(true)
      end
    end
  end

  describe '#literal' do
    context 'with defaults' do
      it 'defines a literal param' do
        object = described_class.new
        object.literal(:version, value: '1.0')

        expect(object.params[:version][:type]).to eq(:literal)
        expect(object.params[:version][:deprecated]).to be(false)
        expect(object.params[:version][:optional]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.literal(
          :version,
          as: :api_version,
          default: '1.0',
          deprecated: true,
          description: 'The version',
          optional: true,
          value: '2.0',
        )

        param = object.params[:version]
        expect(param[:as]).to eq(:api_version)
        expect(param[:default]).to eq('1.0')
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The version')
        expect(param[:optional]).to be(true)
        expect(param[:value]).to eq('2.0')
      end
    end
  end

  describe '#merge' do
    it 'registers the type to merge' do
      object = described_class.new
      object.merge(:timestamps)

      expect(object.merged).to eq([:timestamps])
    end
  end

  describe '#number' do
    context 'with defaults' do
      it 'defines a number param' do
        object = described_class.new
        object.number(:latitude)

        expect(object.params[:latitude][:type]).to eq(:number)
        expect(object.params[:latitude][:deprecated]).to be(false)
        expect(object.params[:latitude][:nullable]).to be(false)
        expect(object.params[:latitude][:optional]).to be(false)
        expect(object.params[:latitude][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.number(
          :latitude,
          as: :lat,
          default: 0.0,
          deprecated: true,
          description: 'The latitude',
          example: 59.33,
          max: 90,
          min: -90,
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:latitude]
        expect(param[:as]).to eq(:lat)
        expect(param[:default]).to eq(0.0)
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The latitude')
        expect(param[:example]).to eq(59.33)
        expect(param[:max]).to eq(90)
        expect(param[:min]).to eq(-90)
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#number?' do
    context 'with defaults' do
      it 'defines an optional number param' do
        object = described_class.new
        object.number?(:score)

        expect(object.params[:score][:type]).to eq(:number)
        expect(object.params[:score][:optional]).to be(true)
      end
    end
  end

  describe '#object' do
    context 'with defaults' do
      it 'defines an object param' do
        object = described_class.new
        object.object(:address) { string :street }

        expect(object.params[:address][:type]).to eq(:object)
        expect(object.params[:address][:deprecated]).to be(false)
        expect(object.params[:address][:nullable]).to be(false)
        expect(object.params[:address][:optional]).to be(false)
        expect(object.params[:address][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.object(
          :address,
          as: :location,
          default: {},
          deprecated: true,
          description: 'The address',
          nullable: true,
          optional: true,
          required: false,
        ) { string :street }

        param = object.params[:address]
        expect(param[:as]).to eq(:location)
        expect(param[:default]).to eq({})
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The address')
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#object?' do
    context 'with defaults' do
      it 'defines an optional object param' do
        object = described_class.new
        object.object?(:metadata) { string :key }

        expect(object.params[:metadata][:type]).to eq(:object)
        expect(object.params[:metadata][:optional]).to be(true)
      end
    end
  end

  describe '#param' do
    context 'with defaults' do
      it 'registers the param' do
        object = described_class.new
        object.param(:title, type: :string)

        expect(object.params[:title][:name]).to eq(:title)
        expect(object.params[:title][:type]).to eq(:string)
        expect(object.params[:title][:deprecated]).to be(false)
        expect(object.params[:title][:nullable]).to be(false)
        expect(object.params[:title][:optional]).to be(false)
        expect(object.params[:title][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'stores all options' do
        object = described_class.new
        object.param(
          :amount,
          as: :total,
          default: 0,
          deprecated: true,
          description: 'The amount',
          enum: %w[low high],
          example: 99.99,
          format: :double,
          max: 1000,
          min: 0,
          nullable: true,
          optional: true,
          required: false,
          type: :decimal,
          value: 42,
        )

        param = object.params[:amount]
        expect(param[:as]).to eq(:total)
        expect(param[:default]).to eq(0)
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The amount')
        expect(param[:enum]).to eq(%w[low high])
        expect(param[:example]).to eq(99.99)
        expect(param[:format]).to eq(:double)
        expect(param[:max]).to eq(1000)
        expect(param[:min]).to eq(0)
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
        expect(param[:required]).to be(false)
        expect(param[:type]).to eq(:decimal)
        expect(param[:value]).to eq(42)
      end
    end
  end

  describe '#reference' do
    context 'with defaults' do
      it 'defines a reference param' do
        object = described_class.new
        object.reference(:customer)

        expect(object.params[:customer][:type]).to eq(:customer)
        expect(object.params[:customer][:deprecated]).to be(false)
        expect(object.params[:customer][:nullable]).to be(false)
        expect(object.params[:customer][:optional]).to be(false)
        expect(object.params[:customer][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.reference(
          :billing_address,
          as: :address,
          default: nil,
          deprecated: true,
          description: 'The billing address',
          nullable: true,
          optional: true,
          required: false,
          to: :address,
        )

        param = object.params[:billing_address]
        expect(param[:as]).to eq(:address)
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The billing address')
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
        expect(param[:type]).to eq(:address)
      end
    end
  end

  describe '#reference?' do
    context 'with defaults' do
      it 'defines an optional reference param' do
        object = described_class.new
        object.reference?(:customer)

        expect(object.params[:customer][:type]).to eq(:customer)
        expect(object.params[:customer][:optional]).to be(true)
      end
    end
  end

  describe '#string' do
    context 'with defaults' do
      it 'defines a string param' do
        object = described_class.new
        object.string(:title)

        expect(object.params[:title][:type]).to eq(:string)
        expect(object.params[:title][:deprecated]).to be(false)
        expect(object.params[:title][:nullable]).to be(false)
        expect(object.params[:title][:optional]).to be(false)
        expect(object.params[:title][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.string(
          :title,
          as: :name,
          default: 'Untitled',
          deprecated: true,
          description: 'The title',
          enum: %w[draft published],
          example: 'Invoice #1',
          format: :email,
          max: 100,
          min: 1,
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:title]
        expect(param[:as]).to eq(:name)
        expect(param[:default]).to eq('Untitled')
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The title')
        expect(param[:enum]).to eq(%w[draft published])
        expect(param[:example]).to eq('Invoice #1')
        expect(param[:format]).to eq(:email)
        expect(param[:max]).to eq(100)
        expect(param[:min]).to eq(1)
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#string?' do
    context 'with defaults' do
      it 'defines an optional string param' do
        object = described_class.new
        object.string?(:title)

        expect(object.params[:title][:type]).to eq(:string)
        expect(object.params[:title][:optional]).to be(true)
      end
    end
  end

  describe '#time' do
    context 'with defaults' do
      it 'defines a time param' do
        object = described_class.new
        object.time(:opens_at)

        expect(object.params[:opens_at][:type]).to eq(:time)
        expect(object.params[:opens_at][:deprecated]).to be(false)
        expect(object.params[:opens_at][:nullable]).to be(false)
        expect(object.params[:opens_at][:optional]).to be(false)
        expect(object.params[:opens_at][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.time(
          :opens_at,
          as: :opening_time,
          default: '09:00',
          deprecated: true,
          description: 'The opening time',
          example: '09:00',
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:opens_at]
        expect(param[:as]).to eq(:opening_time)
        expect(param[:default]).to eq('09:00')
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The opening time')
        expect(param[:example]).to eq('09:00')
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#time?' do
    context 'with defaults' do
      it 'defines an optional time param' do
        object = described_class.new
        object.time?(:closes_at)

        expect(object.params[:closes_at][:type]).to eq(:time)
        expect(object.params[:closes_at][:optional]).to be(true)
      end
    end
  end

  describe '#union' do
    context 'with defaults' do
      it 'defines a union param' do
        object = described_class.new
        object.union(:payment_method, discriminator: :type) do
          variant tag: 'card' do
            object { string :last_four }
          end
        end

        expect(object.params[:payment_method][:type]).to eq(:union)
        expect(object.params[:payment_method][:deprecated]).to be(false)
        expect(object.params[:payment_method][:nullable]).to be(false)
        expect(object.params[:payment_method][:optional]).to be(false)
        expect(object.params[:payment_method][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.union(
          :payment_method,
          as: :payment,
          default: nil,
          deprecated: true,
          description: 'The payment method',
          discriminator: :type,
          nullable: true,
          optional: true,
          required: false,
        ) do
          variant tag: 'card' do
            object { string :last_four }
          end
        end

        param = object.params[:payment_method]
        expect(param[:as]).to eq(:payment)
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The payment method')
        expect(param[:discriminator]).to eq(:type)
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#union?' do
    context 'with defaults' do
      it 'defines an optional union param' do
        object = described_class.new
        object.union?(:notification, discriminator: :type) do
          variant tag: 'email' do
            object { string :address }
          end
        end

        expect(object.params[:notification][:type]).to eq(:union)
        expect(object.params[:notification][:optional]).to be(true)
      end
    end
  end

  describe '#uuid' do
    context 'with defaults' do
      it 'defines a uuid param' do
        object = described_class.new
        object.uuid(:id)

        expect(object.params[:id][:type]).to eq(:uuid)
        expect(object.params[:id][:deprecated]).to be(false)
        expect(object.params[:id][:nullable]).to be(false)
        expect(object.params[:id][:optional]).to be(false)
        expect(object.params[:id][:required]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        object = described_class.new
        object.uuid(
          :id,
          as: :identifier,
          default: nil,
          deprecated: true,
          description: 'The ID',
          example: '550e8400-e29b-41d4-a716-446655440000',
          nullable: true,
          optional: true,
          required: false,
        )

        param = object.params[:id]
        expect(param[:as]).to eq(:identifier)
        expect(param[:deprecated]).to be(true)
        expect(param[:description]).to eq('The ID')
        expect(param[:example]).to eq('550e8400-e29b-41d4-a716-446655440000')
        expect(param[:nullable]).to be(true)
        expect(param[:optional]).to be(true)
      end
    end
  end

  describe '#uuid?' do
    context 'with defaults' do
      it 'defines an optional uuid param' do
        object = described_class.new
        object.uuid?(:parent_id)

        expect(object.params[:parent_id][:type]).to eq(:uuid)
        expect(object.params[:parent_id][:optional]).to be(true)
      end
    end
  end
end
