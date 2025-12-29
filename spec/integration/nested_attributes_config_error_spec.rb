# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested Attributes Configuration Errors', type: :request do
  # This spec tests that helpful errors are raised when writable: true
  # is set on an association but the model lacks accepts_nested_attributes_for

  describe 'Configuration Error Detection' do
    it 'raises ConfigurationError when defining resource with writable association but no accepts_nested_attributes_for' do
      # Create a temporary model without accepts_nested_attributes_for
      temp_model = Class.new(ApplicationRecord) do
        self.table_name = 'posts' # Reuse posts table
        has_many :comments, dependent: :destroy, foreign_key: 'post_id'
        # NOTE: No accepts_nested_attributes_for :comments
        validates :title, presence: true

        def self.name
          'TempArticleModel'
        end
      end

      # Attempting to create a resource with writable: true should raise ConfigurationError
      expect do
        Class.new(Apiwork::Schema::Base) do
          model temp_model
          root :temp_article

          attribute :id
          attribute :title, writable: true

          # This should raise ConfigurationError because TempArticleModel
          # doesn't have accepts_nested_attributes_for :comments
          has_many :comments, writable: true
        end
      end.to raise_error(
        Apiwork::ConfigurationError,
        /doesn't accept nested attributes.*accepts_nested_attributes_for :comments/,
      )
    end

    it 'succeeds when model has accepts_nested_attributes_for configured' do
      # Create a model WITH accepts_nested_attributes_for
      temp_model = Class.new(ApplicationRecord) do
        self.table_name = 'posts'
        has_many :comments, dependent: :destroy, foreign_key: 'post_id'
        accepts_nested_attributes_for :comments, allow_destroy: true # Properly configured
        validates :title, presence: true

        def self.name
          'ProperlyConfiguredModel'
        end
      end

      # This should NOT raise an error
      expect do
        Class.new(Apiwork::Schema::Base) do
          model temp_model
          root :proper_article

          attribute :id
          attribute :title, writable: true

          # This is fine because ProperlyConfiguredModel has accepts_nested_attributes_for
          has_many :comments, writable: true
        end
      end.not_to raise_error
    end
  end

  describe 'Error Message Quality' do
    it 'provides helpful error message with model name and exact fix' do
      temp_model = Class.new(ApplicationRecord) do
        self.table_name = 'posts'
        has_many :comments, dependent: :destroy, foreign_key: 'post_id'
        validates :title, presence: true

        def self.name
          'TestModelForError'
        end
      end

      begin
        Class.new(Apiwork::Schema::Base) do
          model temp_model

          has_many :comments, writable: true
        end
        raise 'Expected ConfigurationError to be raised'
      rescue Apiwork::ConfigurationError => e
        # Error message should include:
        expect(e.message).to include('TestModelForError')
        expect(e.message).to include("doesn't accept nested attributes")
        expect(e.message).to include('comments')
        expect(e.message).to include('accepts_nested_attributes_for :comments')
      end
    end
  end

  # NOTE: Runtime behavior with proper configuration is already tested in
  # spec/integration/nested_attributes_spec.rb, so we don't duplicate it here
end
