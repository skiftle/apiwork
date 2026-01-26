# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Missing Model Error Handling' do
  describe 'when auto-detection fails to find model' do
    it 'raises ConfigurationError with helpful message' do
      expect do
        class NonExistentModelRepresentation < Apiwork::Representation::Base
          attribute :id
        end
      end.to raise_error(Apiwork::ConfigurationError, /Could not find model 'NonExistentModel'/) do |error|
        expect(error.message).to include('create the model')
        expect(error.message).to include("declare it explicitly with 'model YourModel'")
        expect(error.message).to include('mark this representation as abstract')
      end
    end

    it 'allows abstract schemas without models' do
      expect do
        class AbstractNoModelRepresentation < Apiwork::Representation::Base
          abstract!
          attribute :id
        end
      end.not_to raise_error

      expect(AbstractNoModelRepresentation.model_class).to be_nil
    end

    it 'allows explicit model declaration to override auto-detection' do
      expect do
        class ExplicitModelRepresentation < Apiwork::Representation::Base
          model Post
          attribute :id
        end
      end.not_to raise_error

      expect(ExplicitModelRepresentation.model_class).to eq(Post)
    end

    it 'works correctly when model exists and can be auto-detected' do
      expect do
        class PostRepresentation < Apiwork::Representation::Base
          attribute :id
        end
      end.not_to raise_error

      expect(PostRepresentation.model_class).to eq(Post)
    end
  end

  describe 'error context' do
    it 'includes schema name and expected model in error message' do
      class ContextTestRepresentation < Apiwork::Representation::Base
        attribute :id
      end
      raise 'Expected ConfigurationError to be raised'
    rescue Apiwork::ConfigurationError => e
      expect(e.message).to include('ContextTestRepresentation')
      expect(e.message).to include('ContextTest')
    end
  end
end
