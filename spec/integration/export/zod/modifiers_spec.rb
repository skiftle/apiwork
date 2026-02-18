# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod modifier generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Zod.new(path) }
  let(:output) { generator.generate }

  describe 'Format validators' do
    it 'generates z.uuid() for uuid-formatted fields' do
      expect(output).to include('z.uuid()')
    end

    it 'generates z.email() for email-formatted fields' do
      expect(output).to include('recipient_email: z.email()')
    end

    it 'generates z.url() for url-formatted fields' do
      expect(output).to include('callback_url: z.url()')
    end

    it 'combines format with optional modifier' do
      expect(output).to include('z.url().optional()')
    end
  end

  describe 'Min and max constraints' do
    it 'generates .min() on string fields' do
      expect(output).to include('z.string().min(1)')
    end

    it 'generates .max() on string fields' do
      expect(output).to include('.max(500)')
    end

    it 'generates combined .min().max() on string fields' do
      expect(output).to include('z.string().min(1).max(500)')
    end

    it 'generates .min() on integer pagination fields' do
      expect(output).to match(/number: z\.number\(\)\.int\(\)\.min\(1\)/)
    end

    it 'generates combined .min().max() on integer pagination fields' do
      expect(output).to match(/size: z\.number\(\)\.int\(\)\.min\(1\)\.max\(200\)/)
    end

    it 'combines min/max with optional modifier' do
      expect(output).to include('z.string().min(1).max(500).optional()')
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
      expect(output).to match(/\.nullable\(\)\.optional\(\)/)
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
