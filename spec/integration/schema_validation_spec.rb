# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Schema Validation', type: :apiwork do
  describe 'Schema.validate!' do
    it 'validates all attribute definitions for PostSchema' do
      # This ensures all attributes are properly configured
      # and helps catch configuration errors that would otherwise appear at runtime
      expect { Api::V1::PostSchema.validate! }.not_to raise_error
    end

    it 'validates all attribute definitions for CommentSchema' do
      expect { Api::V1::CommentSchema.validate! }.not_to raise_error
    end

    context 'when attribute does not exist' do
      it 'raises ConfigurationError' do
        schema_class = Class.new(Apiwork::Schema::Base) do
          model Post

          attribute :nonexistent_column
        end

        expect { schema_class.validate! }.to raise_error(Apiwork::ConfigurationError, /Undefined resource attribute/)
      end
    end
  end
end
