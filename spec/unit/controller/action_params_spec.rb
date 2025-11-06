# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Controller::ActionParams do
  # Mock controller class for testing
  let(:controller_class) do
    Class.new do
      include Apiwork::Controller::ActionParams

      attr_accessor :action_name, :validated_request

      def initialize(action, params)
        @action_name = action
        @validated_request = OpenStruct.new(params: params)
      end
    end
  end

  describe '#transform_nested_attributes' do
    let(:controller) { controller_class.new(:create, {}) }

    context 'when resource has writable association WITH accepts_nested_attributes_for' do
      let(:model_class) do
        Class.new do
          def self.nested_attributes_options
            { comments: { allow_destroy: true } }
          end

          def self.name
            'TestPost'
          end
        end
      end

      let(:nested_resource_class) do
        Class.new do
          def self.association_definitions
            {}
          end
        end
      end

      let(:assoc_def) do
        double('AssociationDefinition',
          writable_for?: true,
          schema_class: 'TestCommentSchema',
          allow_destroy?: true
        )
      end

      let(:resource) do
        double('Schema',
          model_class: model_class,
          association_definitions: { comments: assoc_def }
        )
      end

      before do
        stub_const('TestCommentSchema', nested_resource_class)
      end

      it 'transforms association key to _attributes format' do
        params = { title: 'Test', comments: [{ content: 'Comment' }] }

        result = controller.send(:transform_nested_attributes, params, resource, :create)

        expect(result).to have_key(:comments_attributes)
        expect(result).not_to have_key(:comments)
        expect(result[:comments_attributes]).to eq([{ content: 'Comment' }])
      end

      it 'handles array values (has_many)' do
        params = { comments: [{ content: 'C1' }, { content: 'C2' }] }

        result = controller.send(:transform_nested_attributes, params, resource, :create)

        expect(result[:comments_attributes]).to be_an(Array)
        expect(result[:comments_attributes].length).to eq(2)
      end

      it 'handles hash values (belongs_to, has_one)' do
        params = { comments: { content: 'Single' } }

        result = controller.send(:transform_nested_attributes, params, resource, :create)

        expect(result[:comments_attributes]).to be_a(Hash)
        expect(result[:comments_attributes][:content]).to eq('Single')
      end

      it 'preserves _destroy flag' do
        params = { comments: [{ id: 1, _destroy: true }] }

        result = controller.send(:transform_nested_attributes, params, resource, :create)

        expect(result[:comments_attributes][0][:_destroy]).to be true
      end

      it 'does not transform if association key not present' do
        params = { title: 'Test' }

        result = controller.send(:transform_nested_attributes, params, resource, :create)

        expect(result).to eq({ title: 'Test' })
        expect(result).not_to have_key(:comments_attributes)
      end
    end

    # Note: Validation of accepts_nested_attributes_for happens at resource definition time
    # in AssociationDefinition#validate_nested_attributes!, not during transformation.
    # See spec/integration/nested_attributes_config_error_spec.rb for those tests.

    context 'when association is not writable for the action' do
      let(:model_class) do
        Class.new do
          def self.nested_attributes_options
            { comments: {} }
          end
        end
      end

      let(:assoc_def) do
        double('AssociationDefinition',
          writable_for?: false, # Not writable for this action
          resource_class: 'TestCommentResource'
        )
      end

      let(:resource) do
        double('Resource',
          model_class: model_class,
          association_definitions: { comments: assoc_def }
        )
      end

      it 'does not transform the association' do
        params = { comments: [{ content: 'Comment' }] }

        result = controller.send(:transform_nested_attributes, params, resource, :show)

        expect(result).to have_key(:comments)
        expect(result).not_to have_key(:comments_attributes)
      end
    end

    context 'deeply nested associations' do
      let(:deeply_nested_resource) do
        double('DeeplyNestedResource',
          association_definitions: {}
        )
      end

      let(:nested_resource) do
        double('NestedResource',
          association_definitions: { replies: nested_assoc_def }
        )
      end

      let(:nested_assoc_def) do
        double('NestedAssociationDefinition',
          writable_for?: true,
          schema_class: deeply_nested_resource
        )
      end

      let(:model_class) do
        Class.new do
          def self.nested_attributes_options
            { comments: { allow_destroy: true } }
          end

          def self.name
            'TestPost'
          end
        end
      end

      let(:nested_model_class) do
        Class.new do
          def self.nested_attributes_options
            { replies: {} }
          end

          def self.name
            'TestComment'
          end
        end
      end

      let(:assoc_def) do
        double('AssociationDefinition',
          writable_for?: true,
          schema_class: nested_resource
        )
      end

      let(:resource) do
        double('Schema',
          model_class: model_class,
          association_definitions: { comments: assoc_def }
        )
      end

      before do
        allow(nested_resource).to receive(:model_class).and_return(nested_model_class)
      end

      it 'recursively transforms nested associations' do
        params = {
          title: 'Post',
          comments: [
            {
              content: 'Comment',
              replies: [{ content: 'Reply' }]
            }
          ]
        }

        result = controller.send(:transform_nested_attributes, params, resource, :create)

        expect(result[:comments_attributes]).to be_an(Array)
        expect(result[:comments_attributes][0]).to have_key(:replies_attributes)
        expect(result[:comments_attributes][0][:replies_attributes]).to eq([{ content: 'Reply' }])
      end
    end

    context 'edge cases' do
      let(:resource) do
        double('Resource',
          model_class: nil,
          association_definitions: {}
        )
      end

      it 'returns params unchanged if not a hash' do
        result = controller.send(:transform_nested_attributes, 'not a hash', resource, :create)
        expect(result).to eq('not a hash')
      end

      it 'returns params unchanged if resource has no associations' do
        params = { title: 'Test' }
        result = controller.send(:transform_nested_attributes, params, resource, :create)
        expect(result).to eq(params)
      end
    end
  end


  describe '#resolve_nested_schema' do
    let(:controller) { controller_class.new(:create, {}) }

    it 'constantizes string schema class' do
      nested_class = Class.new
      stub_const('TestSchema', nested_class)

      assoc_def = double('AssociationDefinition', schema_class: 'TestSchema')

      result = controller.send(:resolve_nested_schema, assoc_def)
      expect(result).to eq(nested_class)
    end

    it 'returns class directly if already a class' do
      nested_class = Class.new
      assoc_def = double('AssociationDefinition', schema_class: nested_class)

      result = controller.send(:resolve_nested_schema, assoc_def)
      expect(result).to eq(nested_class)
    end

    it 'returns nil if constantize fails' do
      assoc_def = double('AssociationDefinition', schema_class: 'NonExistentClass')

      result = controller.send(:resolve_nested_schema, assoc_def)
      expect(result).to be_nil
    end
  end
end
