# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Abstract Base Schema with Auto-Detection' do
  before(:all) do
    # Create users table if it doesn't exist
    unless ActiveRecord::Base.connection.table_exists?('users')
      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.string :email
          t.string :name
          t.timestamps
        end
      end
    end
  end

  describe 'UserSchema inheriting from abstract BaseSchema' do
    it 'auto-detects User model without explicit model declaration' do
      # UserSchema should have auto-detected User model
      expect(Api::V1::UserSchema.model_class).to eq(User)
      expect(Api::V1::UserSchema.model?).to be true
    end

    it 'auto-detects attribute types from DB' do
      # name attribute should have detected :string type from DB
      name_definition = Api::V1::UserSchema.attribute_definitions[:name]
      expect(name_definition.type).to eq(:string)
    end

    it 'null_to_empty validation works with auto-detected type' do
      # This should NOT raise an error because type was auto-detected as :string
      expect do
        Api::V1::UserSchema.attribute_definitions[:name]
      end.not_to raise_error
    end

    it 'can serialize User objects' do
      user = User.create!(email: 'test@example.com', name: 'Test User')

      result = Api::V1::UserSchema.serialize(user)

      expect(result[:email]).to eq('test@example.com')
      expect(result[:name]).to eq('Test User')
    end

    it 'BaseSchema is abstract and does not trigger auto-detection' do
      # BaseSchema should not have a model
      expect(Api::V1::BaseSchema.respond_to?(:model_class)).to be true
      expect(Api::V1::BaseSchema.model_class).to be_nil
    end
  end
end
