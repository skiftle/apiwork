# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Spec::Typescript do
  before do
    load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)
  end

  let(:path) { '/api/v1' }
  let(:generator) { described_class.new(path) }
  let(:api) { Apiwork::API.find(path) }
  let(:introspect) { api.introspect }

  describe 'default options' do
    it 'has default version' do
      expect(described_class.default_options[:version]).to eq('5')
    end
  end

  describe '#version' do
    it 'uses default version when not specified' do
      gen = described_class.new(path)
      expect(gen.send(:version)).to eq('5')
    end

    it 'allows version override' do
      gen = described_class.new(path, version: '4')
      expect(gen.send(:version)).to eq('4')
    end
  end

  describe 'version validation' do
    it 'accepts valid version 4' do
      expect { described_class.new(path, version: '4') }.not_to raise_error
    end

    it 'accepts valid version 5' do
      expect { described_class.new(path, version: '5') }.not_to raise_error
    end

    it 'raises error for invalid version' do
      expect do
        described_class.new(path, version: '3')
      end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
    end

    it 'raises error for version 6' do
      expect do
        described_class.new(path, version: '6')
      end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
    end

    it 'accepts nil version' do
      expect { described_class.new(path, version: nil) }.not_to raise_error
    end
  end

  describe '#generate' do
    # Generate output lazily on first access (cached within each test)
    let(:output) { generator.generate }

    it 'generates valid TypeScript code' do
      expect(output).to be_a(String)
      expect(output).not_to include("import { z } from 'zod'")
      expect(output).not_to include('Schema')
    end

    it 'does not include Zod imports or schemas' do
      expect(output).not_to include('z.object')
      expect(output).not_to include('z.enum')
      expect(output).not_to include('z.string')
      expect(output).not_to include('z.ZodType')
    end

    describe 'enum types' do
      it 'includes SortDirection enum type' do
        expect(output).to include("export type SortDirection = 'asc' | 'desc'")
      end

      it 'generates enum types with union of literals' do
        # Check that enums are formatted as type = 'value1' | 'value2'
        expect(output).to match(/export type \w+ = '[^']+' \| '[^']+';/)
      end

      it 'sorts enum types alphabetically' do
        lines = output.lines.grep(/export type \w+ = /)
        lines.map { |l| l.match(/export type (\w+) =/)[1] }

        # Filter to just enum types (those with union of literal strings)
        enum_lines = lines.select { |l| l.include?("'") }
        enum_type_names = enum_lines.map { |l| l.match(/export type (\w+) =/)[1] }

        expect(enum_type_names).to eq(enum_type_names.sort)
      end
    end

    describe 'interface types' do
      it 'includes StringFilter interface' do
        expect(output).to include('export interface StringFilter')
        expect(output).to match(/export interface StringFilter \{[\s\S]*?\}/)
      end

      it 'includes IntegerFilter interface' do
        expect(output).to include('export interface IntegerFilter')
      end

      it 'includes DatetimeFilter interface' do
        expect(output).to include('export interface DatetimeFilter')
      end

      # DateFilter and UuidFilter are not included because no schema uses date or uuid types
      # Only types actually used by schemas are registered with lazy loading

      it 'includes NullableBooleanFilter interface' do
        expect(output).to include('export interface NullableBooleanFilter')
      end

      it 'includes schema-specific page interfaces' do
        # Schema-specific page types like UserPage, PostPage, etc.
        expect(output).to include('export interface UserPage')
        expect(output).to include('export interface PostPage')
      end

      it 'sorts interface types alphabetically' do
        interface_lines = output.lines.grep(/export interface \w+/)
        interface_names = interface_lines.map { |l| l.match(/export interface (\w+)/)[1] }

        expect(interface_names).to eq(interface_names.sort)
      end
    end

    describe 'union types from filters' do
      it 'includes AccountStatusFilter union type for filterable enum' do
        # AccountSchema has status with filterable: true
        expect(output).to include('export type AccountStatusFilter = ')
        expect(output).to match(/AccountStatusFilter = AccountStatus \| \{/)
      end

      it 'does NOT include SortDirectionFilter for non-filterable enum' do
        # sort_direction enum is NOT used by any filterable schema attribute
        expect(output).not_to include('export type SortDirectionFilter = ')
      end

      it 'generates partial object variants correctly' do
        # AccountStatusFilter should have eq? and in? as optional fields
        expect(output).to match(/AccountStatusFilter = AccountStatus \| \{ eq\?: AccountStatus; in\?: AccountStatus\[\] \}/)
      end
    end

    describe 'alphabetical sorting' do
      it 'sorts ALL types alphabetically (enums and interfaces together)' do
        type_lines = output.lines.grep(/^export (type|interface) \w+/)
        type_names = type_lines.map { |l| l.match(/^export (?:type|interface) (\w+)/)[1] }

        expect(type_names).to eq(type_names.sort),
                              "Expected types in alphabetical order but got: #{type_names.inspect}"
      end

      it 'enums appear before interfaces if alphabetically earlier' do
        # Get all type declarations
        declarations = []
        output.lines.each do |line|
          next unless line =~ /^export (type|interface) (\w+)/

          kind = Regexp.last_match(1)
          name = Regexp.last_match(2)
          declarations << { name: name, kind: kind }
        end

        # Verify they're in alphabetical order by name
        names = declarations.map { |d| d[:name] }
        expect(names).to eq(names.sort)
      end
    end

    describe 'property sorting' do
      it 'sorts interface properties alphabetically' do
        # Extract StringFilter interface
        string_filter_match = output.match(/export interface StringFilter \{([\s\S]*?)\}/)
        expect(string_filter_match).not_to be_nil

        properties_block = string_filter_match[1]
        property_lines = properties_block.lines.map(&:strip).reject(&:empty?)
        property_names = property_lines.map { |l| l.match(/^(\w+)\??:/)[1] }

        expect(property_names).to eq(property_names.sort),
                                  'Expected StringFilter properties in alphabetical order'
      end

      it 'sorts inline object properties alphabetically' do
        # Check that union object variants have sorted properties
        filter_match = output.match(/AccountStatusFilter = AccountStatus \| \{ (eq\?: AccountStatus; in\?: AccountStatus\[\]) \}/)
        expect(filter_match).not_to be_nil

        # Properties should be: eq, in (alphabetical)
        properties_str = filter_match[1]
        expect(properties_str).to match(/eq\?:.*in\?:/)
      end
    end

    describe 'field types' do
      it 'generates correct primitive types' do
        # String filter should have string types for various fields
        expect(output).to match(/contains\?: string/)
        expect(output).to match(/starts_with\?: string/)
      end

      it 'generates correct array types' do
        # Check for array notation
        expect(output).to match(/in\?: \w+\[\]/)
      end

      it 'generates correct optional fields' do
        # Most filter fields should be optional
        expect(output).to match(/eq\?: /)
        expect(output).to match(/in\?: /)
      end

      it 'generates correct enum references' do
        # Filter unions should reference the enum type (only for filterable enums)
        expect(output).to match(/AccountStatusFilter = AccountStatus \|/)
        expect(output).to match(/eq\?: AccountStatus/)
      end
    end

    describe 'JSON column type mapping' do
      it 'generates object type for :json columns' do
        # Post has metadata :json column, which maps to :object type
        # Since the column is nullable, it generates: metadata?: null | object
        expect(output).to match(/metadata\?: null \| object/)
      end
    end

    describe 'nullable types' do
      it 'generates union with null for nullable fields' do
        # If there are any nullable fields in the test data, verify they have | null
        # This is a placeholder - adjust based on actual test data
        skip 'No nullable fields in test data' unless output.include?('| null')

        expect(output).to match(/: \w+ \| null/)
      end
    end

    describe 'format and whitespace' do
      it 'has consistent indentation for interface properties' do
        interface_match = output.match(/export interface \w+ \{([\s\S]*?)\}/)
        expect(interface_match).not_to be_nil

        properties_block = interface_match[1]
        property_lines = properties_block.lines.reject { |l| l.strip.empty? }

        # All property lines should start with exactly 2 spaces
        expect(property_lines).to all(match(/^  \w+/))
      end

      it 'has double newlines between type declarations' do
        # Check that there are empty lines between declarations
        type_declarations = output.split(/\n\n+/).select { |section| section.match?(/export (type|interface)/) }

        # Should have multiple separate declarations
        expect(type_declarations.length).to be > 1
      end
    end

    describe 'completeness' do
      it 'includes all enum types from introspect data' do
        introspect[:enums].each_key do |enum_name|
          type_name = enum_name.to_s.camelize(:upper)
          expect(output).to include("export type #{type_name} = ")
        end
      end

      it 'includes all custom types from introspect data' do
        introspect[:types].each_key do |type_name|
          pascal_name = type_name.to_s.camelize(:upper)
          expect(output).to match(/export (type|interface) #{pascal_name}/)
        end
      end
    end

    describe 'no runtime code' do
      it 'does not include any Zod schema definitions' do
        expect(output).not_to include('Schema: z.ZodType')
        expect(output).not_to include('z.object')
        expect(output).not_to include('z.string()')
        expect(output).not_to include('z.number()')
      end

      it 'only includes type declarations' do
        # Every export should be type or interface
        export_lines = output.lines.grep(/^export /)

        expect(export_lines).to all(match(/^export (type|interface) /))
      end
    end
  end

  describe 'generator registration' do
    it 'is registered in the registry' do
      expect(Apiwork::Spec.registered?(:typescript)).to be true
    end

    it 'can be retrieved from the registry' do
      expect(Apiwork::Spec.find(:typescript)).to eq(described_class)
    end

    it 'can be used via Apiwork::Spec.generate' do
      output = Apiwork::Spec.generate(:typescript, path)
      expect(output).to be_a(String)
      expect(output).to include('export type')
    end
  end

  describe 'file extension' do
    it 'returns .ts extension' do
      expect(described_class.file_extension).to eq('.ts')
    end
  end

  describe 'content type' do
    it 'returns text/plain content type' do
      expect(described_class.content_type).to eq('text/plain; charset=utf-8')
    end
  end

  describe 'metadata support' do
    before(:all) do
      Apiwork::API.define '/api/ts_metadata_test' do
        type :documented_type, description: 'Type with description' do
          param :value, type: :string
        end

        enum :status, values: %w[active inactive], description: 'Status enum', deprecated: true
      end
      @metadata_output = Apiwork::Spec.generate(:typescript, '/api/ts_metadata_test')
    end

    attr_reader :metadata_output

    after(:all) do
      Apiwork::API.unregister('/api/ts_metadata_test')
    end

    it 'generates type correctly even with metadata' do
      # Metadata doesn't break type generation
      expect(metadata_output).to include('export interface DocumentedType')
      expect(metadata_output).to match(/export interface DocumentedType \{[\s\S]*?\}/)
    end

    it 'generates enum correctly from hash format with values key' do
      # Enum should be generated from enum_data[:values]
      expect(metadata_output).to include("export type Status = 'active' | 'inactive'")
    end

    it 'includes metadata as JSDoc comments' do
      expect(metadata_output).to include("/**\n * Type with description\n */")
      expect(metadata_output).to include("/**\n * Status enum\n */")
    end

    it 'handles deprecated flag without errors' do
      # deprecated metadata should not cause issues
      expect(metadata_output).to include('export type Status')
    end

    it 'generates correct output for type with all metadata fields' do
      Apiwork::API.define '/api/ts_full_metadata' do
        type :full_meta, description: 'desc', example: { x: 1 }, format: 'fmt', deprecated: false do
          param :x, type: :integer
        end
      end

      output = Apiwork::Spec.generate(:typescript, '/api/ts_full_metadata')

      expect(output).to include('export interface FullMeta')
      expect(output).to include('x: number')

      Apiwork::API.unregister('/api/ts_full_metadata')
    end

    it 'generates correct output for enum with all metadata fields' do
      Apiwork::API.define '/api/ts_enum_meta' do
        enum :color, values: %w[red green blue], description: 'desc', example: 'red', deprecated: false
      end

      output = Apiwork::Spec.generate(:typescript, '/api/ts_enum_meta')

      expect(output).to include("export type Color = 'blue' | 'green' | 'red'")

      Apiwork::API.unregister('/api/ts_enum_meta')
    end

    it 'maintains enum value sorting with metadata present' do
      # Enum values should still be sorted alphabetically
      expect(metadata_output).to include("'active' | 'inactive'")
    end

    it 'includes property descriptions as JSDoc' do
      Apiwork::API.define '/api/ts_prop_desc' do
        type :invoice do
          param :amount, type: :decimal, description: 'Total amount in cents'
          param :currency, type: :string
        end
      end

      output = Apiwork::Spec.generate(:typescript, '/api/ts_prop_desc')

      expect(output).to include('/** Total amount in cents */')
      expect(output).not_to include('/** currency')

      Apiwork::API.unregister('/api/ts_prop_desc')
    end

    it 'includes @example in JSDoc when example provided' do
      Apiwork::API.define '/api/ts_example' do
        type :price, description: 'Price object', example: { amount: 99 } do
          param :amount, type: :integer, example: 99
        end
      end

      output = Apiwork::Spec.generate(:typescript, '/api/ts_example')

      expect(output).to include('@example {:amount=>99}')
      expect(output).to include('@example 99')

      Apiwork::API.unregister('/api/ts_example')
    end

    it 'does not generate empty JSDoc when no description' do
      Apiwork::API.define '/api/ts_no_desc' do
        type :simple do
          param :value, type: :string
        end
      end

      output = Apiwork::Spec.generate(:typescript, '/api/ts_no_desc')

      expect(output).not_to include('/**')
      expect(output).to include('export interface Simple')

      Apiwork::API.unregister('/api/ts_no_desc')
    end
  end

  describe 'unknown type mapping' do
    let(:introspection) { Apiwork::API.introspect('/api/v1') }
    let(:mapper) { Apiwork::Spec::TypescriptMapper.new(introspection: introspection) }

    it 'maps :unknown to unknown' do
      result = mapper.send(:map_primitive, :unknown)
      expect(result).to eq('unknown')
    end

    it 'uses unknown as fallback for unmapped types' do
      result = mapper.send(:map_primitive, :some_unmapped_type)
      expect(result).to eq('unknown')
    end
  end
end
