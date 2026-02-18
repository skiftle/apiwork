# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript modifier generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  describe 'JSDoc annotations' do
    it 'generates JSDoc for description' do
      expect(output).to include('/** Payment terms and notes */')
    end

    it 'generates JSDoc for profile description' do
      expect(output).to include('Billing profile with personal settings')
    end

    it 'generates JSDoc with example' do
      expect(output).to match(/@example/)
    end
  end

  describe 'Description on types' do
    it 'generates description JSDoc on profile interface' do
      expect(output).to include('/** Billing profile with personal settings */')
    end
  end

  describe 'Optional vs nullable distinction' do
    it 'generates optional fields with question mark' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/items\?:/)
    end

    it 'generates nullable fields with null union' do
      invoice_interface = extract_interface(output, 'Invoice')

      expect(invoice_interface).to match(/notes: null \| string/)
    end

    it 'generates nullable bio on profile' do
      profile_interface = extract_interface(output, 'Profile')

      expect(profile_interface).to match(/bio: null \| string/)
    end
  end

  describe 'Key format with camelCase' do
    let(:path) { '/api/v2' }

    it 'generates camelCase property names' do
      expect(output).to match(/createdAt: string/)
    end

    it 'includes no snake_case timestamp fields' do
      expect(output).not_to match(/created_at: string/)
    end
  end

  private

  def extract_interface(output, name)
    pattern = /export interface #{name}\s*\{[^}]*\}/m
    match_data = output.match(pattern)
    match_data ? match_data[0] : ''
  end
end
