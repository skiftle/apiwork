# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pagination types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }

  describe 'offset page' do
    let(:page) { types[:invoice_page] }

    it 'has type object' do
      expect(page.type).to eq(:object)
    end

    it 'has number param' do
      param = page.shape[:number]

      expect(param.type).to eq(:integer)
      expect(param.optional?).to be(true)
    end

    it 'has size param' do
      param = page.shape[:size]

      expect(param.type).to eq(:integer)
      expect(param.optional?).to be(true)
    end
  end

  describe 'cursor page' do
    let(:page) { types[:activity_page] }

    it 'has type object' do
      expect(page.type).to eq(:object)
    end

    it 'has after param' do
      param = page.shape[:after]

      expect(param.type).to eq(:string)
      expect(param.optional?).to be(true)
    end

    it 'has before param' do
      param = page.shape[:before]

      expect(param.type).to eq(:string)
      expect(param.optional?).to be(true)
    end

    it 'has size param' do
      param = page.shape[:size]

      expect(param.type).to eq(:integer)
      expect(param.optional?).to be(true)
    end

    it 'excludes offset params' do
      expect(page.shape.keys).not_to include(:number)
    end
  end

  describe 'offset pagination metadata' do
    let(:metadata) { types[:offset_pagination] }

    it 'has type object' do
      expect(metadata.type).to eq(:object)
    end

    it 'has required current page' do
      param = metadata.shape[:current]

      expect(param.type).to eq(:integer)
      expect(param.optional?).to be(false)
    end

    it 'has required total page count' do
      param = metadata.shape[:total]

      expect(param.type).to eq(:integer)
      expect(param.optional?).to be(false)
    end

    it 'has required items count' do
      param = metadata.shape[:items]

      expect(param.type).to eq(:integer)
      expect(param.optional?).to be(false)
    end

    it 'has nullable next and prev pages' do
      expect(metadata.shape[:next].nullable?).to be(true)
      expect(metadata.shape[:prev].nullable?).to be(true)
    end
  end

  describe 'cursor pagination metadata' do
    let(:metadata) { types[:cursor_pagination] }

    it 'has type object' do
      expect(metadata.type).to eq(:object)
    end

    it 'has nullable next cursor' do
      param = metadata.shape[:next]

      expect(param.type).to eq(:string)
      expect(param.nullable?).to be(true)
    end

    it 'has nullable prev cursor' do
      param = metadata.shape[:prev]

      expect(param.type).to eq(:string)
      expect(param.nullable?).to be(true)
    end
  end
end
