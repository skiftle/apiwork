# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Introspection param types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }

  describe 'Scalar params' do
    it 'returns string param with scalar predicate' do
      param = introspection.types[:invoice].shape[:number]

      expect(param.type).to eq(:string)
      expect(param.scalar?).to be(true)
      expect(param.string?).to be(true)
      expect(param.boundable?).to be(true)
    end

    it 'returns integer param with numeric predicate' do
      param = introspection.types[:invoice].shape[:id]

      expect(param.type).to eq(:integer)
      expect(param.scalar?).to be(true)
      expect(param.integer?).to be(true)
      expect(param.numeric?).to be(true)
      expect(param.boundable?).to be(true)
    end

    it 'returns boolean param with scalar predicate' do
      param = introspection.types[:invoice].shape[:sent]

      expect(param.type).to eq(:boolean)
      expect(param.scalar?).to be(true)
      expect(param.boolean?).to be(true)
    end

    it 'returns decimal param with numeric predicate' do
      param = introspection.types[:payment].shape[:amount]

      expect(param.type).to eq(:decimal)
      expect(param.scalar?).to be(true)
      expect(param.decimal?).to be(true)
      expect(param.numeric?).to be(true)
      expect(param.boundable?).to be(true)
    end

    it 'returns date param with scalar predicate' do
      param = introspection.types[:invoice].shape[:due_on]

      expect(param.type).to eq(:date)
      expect(param.scalar?).to be(true)
      expect(param.date?).to be(true)
    end

    it 'returns datetime param with scalar predicate' do
      param = introspection.types[:invoice].shape[:created_at]

      expect(param.type).to eq(:datetime)
      expect(param.scalar?).to be(true)
      expect(param.datetime?).to be(true)
    end

    it 'returns time param with scalar predicate' do
      param = introspection.types[:profile].shape[:preferred_contact_time]

      expect(param.type).to eq(:time)
      expect(param.scalar?).to be(true)
      expect(param.time?).to be(true)
    end

    it 'returns unknown param for unrecognized column types' do
      param = introspection.types[:invoice].shape[:metadata]

      expect(param.type).to eq(:unknown)
      expect(param.unknown?).to be(true)
      expect(param.scalar?).to be(false)
    end
  end

  describe 'String param format' do
    it 'returns format on string param with uuid format' do
      param = introspection.types[:profile].shape[:external_id]

      expect(param.type).to eq(:string)
      expect(param.format).to eq(:uuid)
      expect(param.formattable?).to be(true)
    end
  end

  describe 'Integer-backed enum with enum reference' do
    it 'returns enum reference on status param' do
      param = introspection.types[:invoice].shape[:status]

      expect(param.type).to eq(:string)
      expect(param.enum?).to be(true)
      expect(param.enum).to eq(:invoice_status)
      expect(param.enum_reference?).to be(true)
    end

    it 'returns enum reference on method param' do
      param = introspection.types[:payment].shape[:method]

      expect(param.type).to eq(:string)
      expect(param.enum?).to be(true)
      expect(param.enum).to eq(:payment_method)
      expect(param.enum_reference?).to be(true)
    end
  end

  describe 'Complex params' do
    it 'returns reference param for associations' do
      param = introspection.types[:payment].shape[:customer]

      expect(param.type).to eq(:reference)
      expect(param.reference?).to be(true)
      expect(param.reference).to eq(:customer)
      expect(param.scalar?).to be(false)
    end

    it 'returns array param for has_many associations' do
      param = introspection.types[:invoice].shape[:items]

      expect(param.type).to eq(:array)
      expect(param.array?).to be(true)
      expect(param.of.type).to eq(:reference)
      expect(param.boundable?).to be(true)
      expect(param.scalar?).to be(false)
    end

    it 'returns object param for meta shapes' do
      body_params = introspection.types[:invoice_create_success_response_body].shape
      param = body_params[:meta]

      expect(param.type).to eq(:object)
      expect(param.object?).to be(true)
      expect(param.partial?).to be(false)
      expect(param.scalar?).to be(false)
    end

    it 'returns union type with predicates' do
      customer = introspection.types[:customer]

      expect(customer.type).to eq(:union)
      expect(customer.union?).to be(true)
      expect(customer.variants).not_to be_empty
    end
  end

  describe 'Param base predicates' do
    it 'returns optional true for optional params' do
      param = introspection.types[:invoice_show_success_response_body].shape[:meta]

      expect(param.optional?).to be(true)
    end

    it 'returns optional false for required params' do
      param = introspection.types[:invoice].shape[:number]

      expect(param.optional?).to be(false)
    end

    it 'returns nullable true for nullable params' do
      param = introspection.types[:invoice].shape[:due_on]

      expect(param.nullable?).to be(true)
    end

    it 'returns nullable false for non-nullable params' do
      param = introspection.types[:invoice].shape[:number]

      expect(param.nullable?).to be(false)
    end

    it 'returns description when set' do
      param = introspection.types[:address].shape[:street]

      expect(param.description).to eq('Street address line')
    end

    it 'returns deprecated true when set' do
      param = introspection.types[:address].shape[:country]

      expect(param.deprecated?).to be(true)
    end

    it 'returns deprecated false by default' do
      param = introspection.types[:address].shape[:city]

      expect(param.deprecated?).to be(false)
    end
  end
end
