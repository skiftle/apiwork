# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod modifier generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Zod.new(path) }
  let(:output) { generator.generate }

  describe 'UUID validation' do
    it 'generates uuid fields with z.uuid()' do
      expect(output).to include('z.uuid()')
    end
  end

  describe 'Nullable modifier' do
    it 'generates nullable fields with .nullable()' do
      expect(output).to include('.nullable()')
    end
  end

  describe 'Optional modifier' do
    it 'generates optional fields with .optional()' do
      expect(output).to include('.optional()')
    end
  end

  describe 'Combined optional and nullable' do
    it 'generates nullable optional fields with both modifiers' do
      expect(output).to match(/\.nullable\(\)\.optional\(\)|\.optional\(\)\.nullable\(\)/)
    end
  end

  describe 'Key format with camelCase' do
    let(:generator) { Apiwork::Export::Zod.new('/api/v1', key_format: :camel) }

    it 'generates camelCase property names' do
      expect(output).to match(/createdAt:/)
    end

    it 'includes no snake_case for timestamp fields' do
      expect(output).not_to match(/created_at:.*z\./)
    end
  end
end
