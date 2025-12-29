# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Literal and Discriminated Union Features' do
  describe 'Literal type' do
    let(:contract_class) do
      create_test_contract do
        action :test do
          request do
            body do
              param :status, type: :literal, value: 'archived'
              param :name, type: :string
            end
          end
        end
      end
    end

    let(:definition) { contract_class.action_definition(:test).request_definition.body_param_definition }

    it 'accepts the exact literal value' do
      result = definition.validate({ name: 'Test', status: 'archived' })
      expect(result[:issues]).to be_empty
      expect(result[:params][:status]).to eq('archived')
    end

    it 'rejects different values' do
      result = definition.validate({ name: 'Test', status: 'active' })
      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:value_invalid)
      expect(result[:issues].first.detail).to eq('Invalid value')
    end

    it 'serializes with value in AST' do
      serialized = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize
      expect(serialized[:status][:type]).to eq(:literal)
      expect(serialized[:status][:value]).to eq('archived')
    end

    it 'raises error if value parameter is missing' do
      expect do
        create_test_contract do
          action :test do
            request do
              body do
                param :status, type: :literal
              end
            end
          end
        end
      end.to raise_error(ArgumentError, /Literal type requires a value parameter/)
    end
  end

  describe 'Discriminated union' do
    let(:contract_class) do
      create_test_contract do
        type :string_filter do
          param :value, type: :string
        end

        action :test do
          request do
            body do
              param :filter, discriminator: :kind, type: :union do
                variant tag: 'string', type: :string_filter

                variant tag: 'range', type: :object do
                  param :gte, type: :integer
                  param :lte, required: false, type: :integer
                end
              end
            end
          end
        end
      end
    end

    let(:definition) { contract_class.action_definition(:test).request_definition.body_param_definition }

    it 'validates string variant with correct discriminator' do
      result = definition.validate({ filter: { kind: 'string', value: 'test' } })
      expect(result[:issues]).to be_empty
      expect(result[:params][:filter][:value]).to eq('test')
    end

    it 'validates range variant with correct discriminator' do
      result = definition.validate({ filter: {
                                     gte: 10,
                                     kind: 'range',
                                     lte: 20
                                   } })
      expect(result[:issues]).to be_empty
      expect(result[:params][:filter][:gte]).to eq(10)
      expect(result[:params][:filter][:lte]).to eq(20)
    end

    it 'rejects invalid discriminator value' do
      result = definition.validate({ filter: { kind: 'invalid' } })
      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:value_invalid)
      expect(result[:issues].first.detail).to eq('Invalid value')
    end

    it 'rejects missing discriminator field' do
      result = definition.validate({ filter: { gte: 10 } })
      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:field_missing)
      expect(result[:issues].first.detail).to eq('Required')
    end

    it 'rejects non-hash values for discriminated unions' do
      result = definition.validate({ filter: 'string' })
      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:type_invalid)
    end

    it 'serializes with discriminator in AST' do
      serialized = Apiwork::Introspection::ParamDefinitionSerializer.new(definition).serialize
      expect(serialized[:filter][:type]).to eq(:union)
      expect(serialized[:filter][:discriminator]).to eq(:kind)
      expect(serialized[:filter][:variants]).to be_an(Array)
      expect(serialized[:filter][:variants][0][:tag]).to eq('string')
      expect(serialized[:filter][:variants][1][:tag]).to eq('range')
    end
  end

  describe 'DSL validation errors' do
    it 'raises error when using discriminator without union type' do
      expect do
        create_test_contract do
          action :test do
            request do
              body do
                param :status, discriminator: :kind, type: :string
              end
            end
          end
        end
      end.to raise_error(ArgumentError, /discriminator can only be used with type: :union/)
    end

    it 'raises error when using tag without discriminator' do
      expect do
        create_test_contract do
          action :test do
            request do
              body do
                param :filter, type: :union do
                  variant tag: 'string', type: :string
                end
              end
            end
          end
        end
      end.to raise_error(ArgumentError, /tag can only be used when union has a discriminator/)
    end

    it 'raises error when discriminator is present but variant lacks tag' do
      expect do
        create_test_contract do
          action :test do
            request do
              body do
                param :filter, discriminator: :kind, type: :union do
                  variant type: :string # Missing tag!
                end
              end
            end
          end
        end
      end.to raise_error(ArgumentError, /tag is required for all variants when union has a discriminator/)
    end
  end
end
