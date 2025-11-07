# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Missing Model Error Handling' do
  describe 'when auto-detection fails to find model' do
    it 'raises ConfigurationError with helpful message' do
      expect {
        class NonExistentModelSchema < Apiwork::Schema::Base
          attribute :id
        end
      }.to raise_error(Apiwork::ConfigurationError, /Could not find model 'NonExistentModel'/) do |error|
        expect(error.message).to include("create the model")
        expect(error.message).to include("declare it explicitly with 'model YourModel'")
        expect(error.message).to include("mark this schema as abstract")
      end
    end

    it 'allows abstract schemas without models' do
      expect {
        class AbstractNoModelSchema < Apiwork::Schema::Base
          self.abstract_class = true
          attribute :id
        end
      }.not_to raise_error

      expect(AbstractNoModelSchema.model_class).to be_nil
    end

    it 'allows explicit model declaration to override auto-detection' do
      expect {
        class ExplicitModelSchema < Apiwork::Schema::Base
          model Post
          attribute :id
        end
      }.not_to raise_error

      expect(ExplicitModelSchema.model_class).to eq(Post)
    end

    it 'works correctly when model exists and can be auto-detected' do
      expect {
        class PostSchema < Apiwork::Schema::Base
          attribute :id
        end
      }.not_to raise_error

      expect(PostSchema.model_class).to eq(Post)
    end
  end

  describe 'error context' do
    it 'includes schema name and expected model in error message' do
      begin
        class ContextTestSchema < Apiwork::Schema::Base
          attribute :id
        end
        fail 'Expected ConfigurationError to be raised'
      rescue Apiwork::ConfigurationError => e
        expect(e.message).to include('ContextTestSchema')
        expect(e.message).to include('ContextTest')
      end
    end
  end
end
