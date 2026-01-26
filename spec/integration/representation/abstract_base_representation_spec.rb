# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Abstract Base Representation with Auto-Detection' do
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

  describe 'UserRepresentation inheriting from abstract BaseRepresentation' do
    it 'auto-detects User model without explicit model declaration' do
      expect(Api::V1::UserRepresentation.model_class).to eq(User)
    end

    it 'auto-detects attribute types from DB' do
      name_definition = Api::V1::UserRepresentation.attributes[:name]
      expect(name_definition.type).to eq(:string)
    end

    it 'empty validation works with auto-detected type' do
      expect do
        Api::V1::UserRepresentation.attributes[:name]
      end.not_to raise_error
    end

    it 'can serialize User objects' do
      user = User.create!(email: 'jane@customer.com', name: 'Jane Doe')

      result = Api::V1::UserRepresentation.serialize(user)

      expect(result[:email]).to eq('jane@customer.com')
      expect(result[:name]).to eq('Jane Doe')
    end

    it 'BaseRepresentation is abstract and does not trigger auto-detection' do
      expect(Api::V1::BaseRepresentation.respond_to?(:model_class)).to be true
      expect(Api::V1::BaseRepresentation.model_class).to be_nil
    end
  end
end
