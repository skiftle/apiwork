# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Literal and Discriminated Union Features' do
  describe 'Literal type' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        action :test do
          input do
            param :status, type: :literal, value: 'archived'
            param :name, type: :string
          end
        end
      end
    end

    let(:definition) { contract_class.action_definition(:test).merged_input_definition }

    it 'accepts the exact literal value' do
      result = definition.validate({ status: 'archived', name: 'Test' })
      expect(result[:issues]).to be_empty
      expect(result[:params][:status]).to eq('archived')
    end

    it 'rejects different values' do
      result = definition.validate({ status: 'active', name: 'Test' })
      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:invalid_value)
      expect(result[:issues].first.message).to include('must be exactly')
    end

    it 'serializes with value in AST' do
      serialized = definition.as_json
      expect(serialized[:status][:type]).to eq(:literal)
      expect(serialized[:status][:value]).to eq('archived')
    end

    it 'raises error if value parameter is missing' do
      expect do
        Class.new(Apiwork::Contract::Base) do
          action :test do
            input do
              param :status, type: :literal
            end
          end
        end
      end.to raise_error(ArgumentError, /Literal type requires a value parameter/)
    end
  end

  describe 'Discriminated union' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        identifier :discriminated_union_test

        # Define custom types first
        type :string_filter do
          param :value, type: :string
        end

        action :test do
          input do
            param :filter, type: :union, discriminator: :kind do
              variant tag: 'string', type: :string_filter

              variant tag: 'range', type: :object do
                param :gte, type: :integer
                param :lte, type: :integer, required: false
              end
            end
          end
        end
      end
    end

    let(:definition) { contract_class.action_definition(:test).merged_input_definition }

    it 'validates string variant with correct discriminator' do
      result = definition.validate({ filter: { kind: 'string', value: 'test' } })
      expect(result[:issues]).to be_empty
      expect(result[:params][:filter][:value]).to eq('test')
    end

    it 'validates range variant with correct discriminator' do
      result = definition.validate({ filter: { kind: 'range', gte: 10, lte: 20 } })
      expect(result[:issues]).to be_empty
      expect(result[:params][:filter][:gte]).to eq(10)
      expect(result[:params][:filter][:lte]).to eq(20)
    end

    it 'rejects invalid discriminator value' do
      result = definition.validate({ filter: { kind: 'invalid' } })
      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:invalid_value)
      expect(result[:issues].first.message).to include('Invalid discriminator value')
    end

    it 'rejects missing discriminator field' do
      result = definition.validate({ filter: { gte: 10 } })
      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:field_missing)
      expect(result[:issues].first.message).to include("Discriminator field 'kind' is required")
    end

    it 'rejects non-hash values for discriminated unions' do
      result = definition.validate({ filter: 'string' })
      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:invalid_type)
    end

    it 'serializes with discriminator in AST' do
      serialized = definition.as_json
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
        Class.new(Apiwork::Contract::Base) do
          action :test do
            input do
              param :status, type: :string, discriminator: :kind
            end
          end
        end
      end.to raise_error(ArgumentError, /discriminator can only be used with type: :union/)
    end

    it 'raises error when using tag without discriminator' do
      expect do
        Class.new(Apiwork::Contract::Base) do
          action :test do
            input do
              param :filter, type: :union do
                variant tag: 'string', type: :string
              end
            end
          end
        end
      end.to raise_error(ArgumentError, /tag can only be used when union has a discriminator/)
    end

    it 'raises error when discriminator is present but variant lacks tag' do
      expect do
        Class.new(Apiwork::Contract::Base) do
          action :test do
            input do
              param :filter, type: :union, discriminator: :kind do
                variant type: :string # Missing tag!
              end
            end
          end
        end
      end.to raise_error(ArgumentError, /tag is required for all variants when union has a discriminator/)
    end
  end
end
