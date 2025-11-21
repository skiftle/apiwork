# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Format validation', type: :integration do
  describe 'ALLOWED_FORMATS constant' do
    it 'defines allowed formats for each type' do
      expect(Apiwork::Schema::AttributeDefinition::ALLOWED_FORMATS).to eq({
                                                                            string: %i[email uuid uri url date date_time ipv4 ipv6 password
                                                                                       hostname],
                                                                            integer: %i[int32 int64],
                                                                            float: %i[float double],
                                                                            decimal: %i[float double],
                                                                            number: %i[float double]
                                                                          })
    end
  end

  describe 'valid formats' do
    it 'accepts valid string formats' do
      schema = Class.new(Apiwork::Schema::Base) { def self.name; "TestFormatSchema" end; abstract }

      %i[email uuid uri url date date_time ipv4 ipv6 password hostname].each do |format|
        expect do
          schema.class_eval do
            attribute :test_field, type: :string, format: format
          end
        end.not_to raise_error
      end
    end

    it 'accepts valid integer formats' do
      schema = Class.new(Apiwork::Schema::Base) { def self.name; "TestFormatSchema" end; abstract }

      %i[int32 int64].each do |format|
        expect do
          schema.class_eval do
            attribute :test_field, type: :integer, format: format
          end
        end.not_to raise_error
      end
    end

    it 'accepts valid number formats' do
      schema = Class.new(Apiwork::Schema::Base) { def self.name; "TestFormatSchema" end; abstract }

      %i[float double].each do |format|
        expect do
          schema.class_eval do
            attribute :test_field, type: :float, format: format
          end
        end.not_to raise_error
      end
    end

    it 'accepts nil format' do
      schema = Class.new(Apiwork::Schema::Base) { def self.name; "TestFormatSchema" end; abstract }

      expect do
        schema.class_eval do
          attribute :test_field, type: :string
        end
      end.not_to raise_error
    end
  end

  describe 'invalid formats' do
    it 'rejects invalid format for string type' do
      schema = Class.new(Apiwork::Schema::Base) { def self.name; "TestFormatSchema" end; abstract }

      expect do
        schema.class_eval do
          attribute :test_field, type: :string, format: :int32
        end
      end.to raise_error(Apiwork::ConfigurationError, /format :int32 is not valid for type :string/)
    end

    it 'rejects invalid format for integer type' do
      schema = Class.new(Apiwork::Schema::Base) { def self.name; "TestFormatSchema" end; abstract }

      expect do
        schema.class_eval do
          attribute :test_field, type: :integer, format: :email
        end
      end.to raise_error(Apiwork::ConfigurationError, /format :email is not valid for type :integer/)
    end

    it 'rejects format for unsupported types' do
      schema = Class.new(Apiwork::Schema::Base) { def self.name; "TestFormatSchema" end; abstract }

      expect do
        schema.class_eval do
          attribute :test_field, type: :boolean, format: :email
        end
      end.to raise_error(Apiwork::ConfigurationError, /format option is not supported for type :boolean/)
    end

    it 'includes allowed formats in error message' do
      schema = Class.new(Apiwork::Schema::Base) { def self.name; "TestFormatSchema" end; abstract }

      expect do
        schema.class_eval do
          attribute :test_field, type: :string, format: :invalid_format
        end
      end.to raise_error(Apiwork::ConfigurationError, /Allowed formats: email, uuid, uri, url, date, date_time, ipv4, ipv6, password, hostname/)
    end
  end
end
