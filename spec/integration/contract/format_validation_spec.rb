# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Format validation', type: :integration do
  describe 'ALLOWED_FORMATS constant' do
    it 'defines allowed formats for each type' do
      expect(Apiwork::Schema::Attribute::ALLOWED_FORMATS).to eq(
        {
          decimal: %i[float double],
          integer: %i[int32 int64],
          number: %i[float double],
          string: %i[email uuid uri url date date_time ipv4 ipv6 password
                     hostname],
        },
      )
    end
  end

  describe 'valid formats' do
    it 'accepts valid string formats' do
      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'TestFormatSchema'
        end
        abstract!
      end

      %i[email uuid uri url date date_time ipv4 ipv6 password hostname].each do |format|
        expect do
          schema.class_eval do
            attribute :test_field, format:, type: :string
          end
        end.not_to raise_error
      end
    end

    it 'accepts valid integer formats' do
      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'TestFormatSchema'
        end
        abstract!
      end

      %i[int32 int64].each do |format|
        expect do
          schema.class_eval do
            attribute :test_field, format:, type: :integer
          end
        end.not_to raise_error
      end
    end

    it 'accepts valid number formats' do
      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'TestFormatSchema'
        end
        abstract!
      end

      %i[float double].each do |format|
        expect do
          schema.class_eval do
            attribute :test_field, format:, type: :number
          end
        end.not_to raise_error
      end
    end

    it 'accepts nil format' do
      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'TestFormatSchema'
        end
        abstract!
      end

      expect do
        schema.class_eval do
          attribute :test_field, type: :string
        end
      end.not_to raise_error
    end
  end

  describe 'invalid formats' do
    it 'rejects invalid format for string type' do
      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'TestFormatSchema'
        end
        abstract!
      end

      expect do
        schema.class_eval do
          attribute :test_field, format: :int32, type: :string
        end
      end.to raise_error(Apiwork::ConfigurationError, /format :int32 is not valid for type :string/)
    end

    it 'rejects invalid format for integer type' do
      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'TestFormatSchema'
        end
        abstract!
      end

      expect do
        schema.class_eval do
          attribute :test_field, format: :email, type: :integer
        end
      end.to raise_error(Apiwork::ConfigurationError, /format :email is not valid for type :integer/)
    end

    it 'rejects format for unsupported types' do
      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'TestFormatSchema'
        end
        abstract!
      end

      expect do
        schema.class_eval do
          attribute :test_field, format: :email, type: :boolean
        end
      end.to raise_error(Apiwork::ConfigurationError, /format option is not supported for type :boolean/)
    end

    it 'includes allowed formats in error message' do
      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'TestFormatSchema'
        end
        abstract!
      end

      expect do
        schema.class_eval do
          attribute :test_field, format: :invalid_format, type: :string
        end
      end.to raise_error(Apiwork::ConfigurationError, /Allowed formats: email, uuid, uri, url, date, date_time, ipv4, ipv6, password, hostname/)
    end
  end
end
