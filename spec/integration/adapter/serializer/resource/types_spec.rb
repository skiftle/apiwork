# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resource serializer types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }
  let(:enums) { introspection.enums }

  describe 'resource object' do
    let(:invoice_type) { types[:invoice] }

    it 'has type object' do
      expect(invoice_type.type).to eq(:object)
    end

    it 'includes all attributes' do
      expect(invoice_type.shape.keys).to include(
        :id,
        :number,
        :status,
        :sent,
        :due_on,
        :notes,
        :metadata,
        :customer_id,
        :created_at,
        :updated_at,
      )
    end

    it 'includes associations' do
      expect(invoice_type.shape.keys).to include(:items, :payments, :attachments, :taggings)
    end
  end

  describe 'attribute types' do
    let(:shape) { types[:invoice].shape }

    it 'maps string columns to string type' do
      expect(shape[:number].type).to eq(:string)
    end

    it 'maps integer columns to integer type' do
      expect(shape[:id].type).to eq(:integer)
    end

    it 'maps boolean columns to boolean type' do
      expect(shape[:sent].type).to eq(:boolean)
    end

    it 'maps date columns to date type' do
      expect(shape[:due_on].type).to eq(:date)
    end

    it 'maps datetime columns to datetime type' do
      expect(shape[:created_at].type).to eq(:datetime)
    end
  end

  describe 'nullable attributes' do
    let(:shape) { types[:invoice].shape }

    it 'marks nullable columns as nullable' do
      expect(shape[:due_on].nullable?).to be(true)
      expect(shape[:notes].nullable?).to be(true)
    end

    it 'marks non-nullable columns as not nullable' do
      expect(shape[:number].nullable?).to be(false)
      expect(shape[:id].nullable?).to be(false)
    end
  end

  describe 'enum attributes' do
    it 'has enum reference on enum columns' do
      param = types[:invoice].shape[:status]

      expect(param.enum?).to be(true)
      expect(param.enum).to eq(:invoice_status)
    end
  end

  describe 'association references' do
    let(:shape) { types[:invoice].shape }

    it 'maps has_many as array of references' do
      param = shape[:items]

      expect(param.type).to eq(:array)
      expect(param.of.type).to eq(:reference)
    end

    it 'maps belongs_to as reference' do
      param = types[:payment].shape[:customer]

      expect(param.type).to eq(:reference)
      expect(param.reference).to eq(:customer)
    end
  end

  describe 'STI union' do
    let(:customer_type) { types[:customer] }

    it 'has type union' do
      expect(customer_type.type).to eq(:union)
    end

    it 'has type discriminator' do
      expect(customer_type.discriminator).to eq(:type)
    end

    it 'has person and company variants' do
      variant_refs = customer_type.variants.map(&:reference)

      expect(variant_refs).to contain_exactly(:company_customer, :person_customer)
    end
  end

  describe 'STI variant objects' do
    it 'has person_customer with inherited and own attributes' do
      shape = types[:person_customer].shape

      expect(shape.keys).to include(:email, :name, :phone, :born_on, :type)
    end

    it 'has company_customer with inherited and own attributes' do
      shape = types[:company_customer].shape

      expect(shape.keys).to include(:email, :name, :phone, :industry, :registration_number, :type)
    end
  end

  describe 'enum types' do
    it 'has invoice_status enum' do
      expect(enums[:invoice_status].values).to contain_exactly('draft', 'overdue', 'paid', 'sent', 'void')
    end

    it 'has payment_method enum' do
      expect(enums[:payment_method].values).to contain_exactly('bank_transfer', 'cash', 'credit_card')
    end

    it 'has payment_status enum' do
      expect(enums[:payment_status].values).to contain_exactly('completed', 'failed', 'pending', 'refunded')
    end
  end
end
