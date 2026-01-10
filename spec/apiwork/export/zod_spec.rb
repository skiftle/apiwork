# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::Zod do
  let(:path) { '/api/v1' }
  let(:generator) { described_class.new(path) }

  describe 'default options' do
    it 'has default version' do
      expect(described_class.default_options[:version]).to eq('4')
    end

    it 'has default key_format' do
      expect(described_class.default_options[:key_format]).to eq(:keep)
    end
  end

  describe 'version validation' do
    it 'accepts valid version 4' do
      expect { described_class.new(path, version: '4') }.not_to raise_error
    end

    it 'raises error for invalid version' do
      expect do
        described_class.new(path, version: '5')
      end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
    end

    it 'accepts nil version' do
      expect { described_class.new(path, version: nil) }.not_to raise_error
    end
  end

  describe '#generate' do
    let(:output) { generator.generate }

    it 'generates valid Zod code' do
      expect(output).to be_a(String)
      expect(output).to include("import { z } from 'zod'")
    end

    describe 'zod import' do
      it 'includes zod import at the top' do
        first_line = output.lines.first
        expect(first_line).to include("import { z } from 'zod'")
      end
    end

    describe 'enum schemas' do
      it 'generates z.enum for enums' do
        expect(output).to match(/export const \w+Schema = z\.enum\(\[/)
      end

      it 'includes SortDirection enum' do
        expect(output).to include("SortDirectionSchema = z.enum(['asc', 'desc'])")
      end

      it 'sorts enum values alphabetically' do
        expect(output).to include("'asc', 'desc'")
        expect(output).not_to include("'desc', 'asc'")
      end
    end

    describe 'object schemas' do
      it 'generates z.object for types' do
        expect(output).to match(/export const \w+Schema = z\.object\(\{/)
      end

      it 'includes property definitions' do
        expect(output).to match(/\w+: z\.\w+/)
      end

      it 'sorts properties alphabetically' do
        filter_match = output.match(/StringFilterSchema = z\.object\(\{([\s\S]*?)\}\)/)
        next unless filter_match

        properties = filter_match[1].scan(/(\w+):/).flatten
        expect(properties).to eq(properties.sort)
      end
    end

    describe 'primitive type mapping' do
      it 'maps string to z.string()' do
        expect(output).to include('z.string()')
      end

      it 'maps integer to z.number().int()' do
        expect(output).to include('z.number().int()')
      end

      it 'maps boolean to z.boolean()' do
        expect(output).to include('z.boolean()')
      end

      it 'maps datetime to z.iso.datetime()' do
        expect(output).to include('z.iso.datetime()')
      end
    end

    describe 'modifiers' do
      it 'applies .nullable() for nullable fields' do
        expect(output).to match(/\.nullable\(\)/)
      end

      it 'applies .optional() for optional fields' do
        expect(output).to match(/\.optional\(\)/)
      end
    end

    describe 'array types' do
      it 'generates z.array() for arrays' do
        expect(output).to match(/z\.array\(/)
      end
    end

    describe 'action schemas' do
      it 'generates request query schemas' do
        expect(output).to match(/export const \w+RequestQuerySchema = z\.object/)
      end

      it 'generates request body schemas' do
        expect(output).to match(/export const \w+RequestBodySchema = z\.object/)
      end

      it 'generates request wrapper schemas' do
        expect(output).to match(/export const \w+RequestSchema = z\.object\(\{[\s\S]*?query:/)
      end

      it 'generates response body schemas' do
        expect(output).to match(/export const \w+ResponseBodySchema = /)
      end

      it 'generates response wrapper schemas' do
        expect(output).to match(/export const \w+ResponseSchema = z\.object\(\{[\s\S]*?body:/)
      end
    end

    describe 'typescript types' do
      it 'includes TypeScript type exports' do
        expect(output).to match(/export type \w+ = /)
      end

      it 'includes TypeScript interface exports' do
        expect(output).to match(/export interface \w+ \{/)
      end

      it 'sorts TypeScript types alphabetically' do
        type_lines = output.lines.grep(/^export (type|interface) \w+/)
        type_names = type_lines.map { |l| l.match(/^export (?:type|interface) (\w+)/)[1] }

        expect(type_names).to eq(type_names.sort)
      end
    end

    describe 'no duplicate definitions' do
      it 'has unique schema names' do
        schema_names = output.scan(/export const (\w+Schema) =/).flatten
        expect(schema_names).to eq(schema_names.uniq)
      end

      it 'has unique type names' do
        type_names = output.scan(/export (?:type|interface) (\w+)/).flatten
        expect(type_names).to eq(type_names.uniq)
      end
    end
  end

  describe 'generator registration' do
    it 'is registered in the registry' do
      expect(Apiwork::Export.registered?(:zod)).to be true
    end

    it 'can be retrieved from the registry' do
      expect(Apiwork::Export.find(:zod)).to eq(described_class)
    end

    it 'can be used via Apiwork::Export.generate' do
      output = Apiwork::Export.generate(:zod, path)
      expect(output).to be_a(String)
      expect(output).to include("import { z } from 'zod'")
    end
  end

  describe 'file extension' do
    it 'returns .ts extension' do
      expect(described_class.file_extension).to eq('.ts')
    end
  end

  describe 'content type' do
    it 'returns text/plain content type' do
      spec = described_class.new(path)
      expect(spec.content_type_for).to eq('text/plain; charset=utf-8')
    end
  end

  describe 'key_format option' do
    it 'keeps keys unchanged with :keep' do
      gen = described_class.new(path, key_format: :keep)
      output = gen.generate
      expect(output).to match(/\b\w+_\w+:/) # snake_case preserved
    end

    it 'transforms keys to camelCase with :camel' do
      Apiwork::API.define '/api/zod_camel_test' do
        object :test_type do
          string :user_name
        end
      end

      gen = described_class.new('/api/zod_camel_test', key_format: :camel)
      output = gen.generate

      expect(output).to include('userName:')
      expect(output).not_to include('user_name:')

      Apiwork::API.unregister('/api/zod_camel_test')
    end
  end

  describe 'union types' do
    before(:all) do
      Apiwork::API.define '/api/zod_union_test' do
        union :payment_method, discriminator: :type do
          variant tag: 'card' do
            object do
              param :type, type: :literal, value: 'card'
              string :last_four
            end
          end
          variant tag: 'bank' do
            object do
              param :type, type: :literal, value: 'bank'
              string :routing_number
            end
          end
        end

        union :simple_union do
          variant do
            object do
              string :name
            end
          end
          variant do
            object do
              integer :id
            end
          end
        end
      end
      @union_output = Apiwork::Export.generate(:zod, '/api/zod_union_test')
    end

    attr_reader :union_output

    after(:all) do
      Apiwork::API.unregister('/api/zod_union_test')
    end

    it 'generates z.discriminatedUnion for discriminated unions' do
      expect(union_output).to include("z.discriminatedUnion('type'")
    end

    it 'generates z.union for non-discriminated unions' do
      expect(union_output).to include('z.union([')
    end
  end

  describe 'self-referencing types' do
    before(:all) do
      Apiwork::API.define '/api/zod_circular_test' do
        object :tree_node do
          string :value
          param :children, of: :tree_node, optional: true, type: :array
        end
      end
      @circular_output = Apiwork::Export.generate(:zod, '/api/zod_circular_test')
    end

    attr_reader :circular_output

    after(:all) do
      Apiwork::API.unregister('/api/zod_circular_test')
    end

    it 'generates schema that references itself' do
      expect(circular_output).to include('TreeNodeSchema = z.object')
      expect(circular_output).to include('z.array(TreeNodeSchema)')
    end

    it 'generates corresponding TypeScript interface' do
      expect(circular_output).to include('export interface TreeNode')
      expect(circular_output).to include('children?: TreeNode[]')
    end
  end

  describe 'literal types' do
    before(:all) do
      Apiwork::API.define '/api/zod_literal_test' do
        object :constants do
          param :string_lit, type: :literal, value: 'hello'
          param :number_lit, type: :literal, value: 42
          param :bool_lit, type: :literal, value: true
        end
      end
      @literal_output = Apiwork::Export.generate(:zod, '/api/zod_literal_test')
    end

    attr_reader :literal_output

    after(:all) do
      Apiwork::API.unregister('/api/zod_literal_test')
    end

    it 'generates z.literal for string values' do
      expect(literal_output).to include("z.literal('hello')")
    end

    it 'generates z.literal for numeric values' do
      expect(literal_output).to include('z.literal(42)')
    end

    it 'generates z.literal for boolean values' do
      expect(literal_output).to include('z.literal(true)')
    end
  end

  describe 'min/max constraints' do
    before(:all) do
      Apiwork::API.define '/api/zod_constraints_test' do
        object :bounded do
          param :limited_string, max: 100, min: 1, type: :string
          param :limited_number, max: 1000, min: 0, type: :integer
          param :limited_array, max: 10, of: :string, type: :array
        end
      end
      @constraints_output = Apiwork::Export.generate(:zod, '/api/zod_constraints_test')
    end

    attr_reader :constraints_output

    after(:all) do
      Apiwork::API.unregister('/api/zod_constraints_test')
    end

    it 'applies .min() constraint to strings' do
      expect(constraints_output).to match(/z\.string\(\)\.min\(1\)/)
    end

    it 'applies .max() constraint to strings' do
      expect(constraints_output).to match(/\.max\(100\)/)
    end

    it 'applies constraints to numbers' do
      expect(constraints_output).to match(/z\.number\(\)\.int\(\)\.min\(0\)\.max\(1000\)/)
    end

    it 'applies constraints to arrays' do
      expect(constraints_output).to match(/z\.array\(.*\)\.max\(10\)/)
    end
  end

  describe 'format mapping' do
    before(:all) do
      Apiwork::API.define '/api/zod_format_test' do
        object :formatted do
          param :email_field, format: :email, type: :string
          param :url_field, format: :url, type: :string
          param :uuid_field, format: :uuid, type: :string
        end
      end
      @format_output = Apiwork::Export.generate(:zod, '/api/zod_format_test')
    end

    attr_reader :format_output

    after(:all) do
      Apiwork::API.unregister('/api/zod_format_test')
    end

    it 'maps email format to z.email()' do
      expect(format_output).to include('z.email()')
    end

    it 'maps url format to z.url()' do
      expect(format_output).to include('z.url()')
    end

    it 'maps uuid format to z.uuid()' do
      expect(format_output).to include('z.uuid()')
    end
  end
end
