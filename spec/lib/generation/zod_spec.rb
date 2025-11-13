# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Generation::Generators::Zod do
  before do
    # Reset registries to prevent accumulation
    Apiwork.reset_registries!
    # Load test API
    load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)
  end

  let(:path) { '/api/v1' }
  let(:generator) { described_class.new(path) }
  let(:api) { Apiwork::API::Registry.find(path) }
  let(:introspect) { api.introspect }

  describe 'default options' do
    it 'has default version 4' do
      expect(described_class.default_options[:version]).to eq('4')
    end
  end

  describe '#version' do
    it 'uses default version when not specified' do
      gen = described_class.new(path)
      expect(gen.send(:version)).to eq('4')
    end

    it 'allows version override' do
      gen = described_class.new(path, version: '3')
      expect(gen.send(:version)).to eq('3')
    end
  end

  describe 'version validation' do
    it 'accepts valid version 3' do
      expect { described_class.new(path, version: '3') }.not_to raise_error
    end

    it 'accepts valid version 4' do
      expect { described_class.new(path, version: '4') }.not_to raise_error
    end

    it 'raises error for invalid version' do
      expect do
        described_class.new(path, version: '2')
      end.to raise_error(ArgumentError, /Invalid version for zod: "2"/)
    end

    it 'raises error for version 5' do
      expect do
        described_class.new(path, version: '5')
      end.to raise_error(ArgumentError, /Invalid version for zod/)
    end

    it 'accepts nil version' do
      expect { described_class.new(path, version: nil) }.not_to raise_error
    end
  end

  # Helper method to detect if a type is recursive (references itself)
  def detect_recursive_type(type_name, type_def)
    referenced_types = extract_type_references(type_def)
    referenced_types.include?(type_name)
  end

  # Helper method to extract type references from a type definition
  # This mirrors the logic in extract_type_references_for_sorting
  def extract_type_references(definition)
    refs = []

    definition.each_value do |param|
      next unless param.is_a?(Hash)

      refs << param[:type] if param[:type].is_a?(Symbol) && !primitive_type?(param[:type])
      refs << param[:of] if param[:of].is_a?(Symbol) && !primitive_type?(param[:of])

      # Union variant references
      if param[:variants].is_a?(Array)
        param[:variants].each do |variant|
          next unless variant.is_a?(Hash)

          refs << variant[:type] if variant[:type].is_a?(Symbol) && !primitive_type?(variant[:type])
          refs << variant[:of] if variant[:of].is_a?(Symbol) && !primitive_type?(variant[:of])

          # Recursively check nested shape in variants
          refs.concat(extract_type_references(variant[:shape])) if variant[:shape].is_a?(Hash)
        end
      end

      # Recursively check nested shapes
      refs.concat(extract_type_references(param[:shape])) if param[:shape].is_a?(Hash)
    end

    refs.uniq
  end

  # Helper method to check if a type is primitive
  def primitive_type?(type)
    %i[string integer boolean datetime date uuid object array decimal float literal union enum].include?(type)
  end

  describe '#generate' do
    let(:output) { generator.generate }

    it 'generates valid TypeScript code' do
      expect(output).to be_a(String)
      expect(output).to include("import { z } from 'zod';")
    end

    describe 'filter and utility schemas from introspect' do
      it 'includes SortDirectionSchema from introspect enums' do
        expect(output).to include("export type SortDirection = 'asc' | 'desc'")
        expect(output).to include('export const SortDirectionSchema: z.ZodType<SortDirection> = z.enum')
        expect(output).to match(/SortDirectionSchema.*asc.*desc/m)
      end

      it 'includes StringFilterSchema from introspect types' do
        expect(output).to include('export interface StringFilter')
        expect(output).to include('export const StringFilterSchema: z.ZodType<StringFilter> = z.object')
      end

      it 'includes IntegerFilterSchema from introspect types' do
        expect(output).to include('export interface IntegerFilter')
        expect(output).to include('export const IntegerFilterSchema: z.ZodType<IntegerFilter> = z.object')
      end

      it 'includes DateFilterSchema from introspect types' do
        expect(output).to include('export interface DateFilter')
        expect(output).to include('export const DateFilterSchema: z.ZodType<DateFilter> = z.object')
      end

      it 'includes UuidFilterSchema from introspect types' do
        expect(output).to include('export interface UuidFilter')
        expect(output).to include('export const UuidFilterSchema: z.ZodType<UuidFilter> = z.object')
      end

      it 'includes BooleanFilterSchema from introspect types' do
        expect(output).to include('export interface BooleanFilter')
        expect(output).to include('export const BooleanFilterSchema: z.ZodType<BooleanFilter> = z.object')
      end

      it 'includes PageParamsSchema (pagination) from introspect types' do
        expect(output).to include('export interface PageParams')
        expect(output).to include('export const PageParamsSchema: z.ZodType<PageParams> = z.object')
      end
    end

    describe 'type schemas' do
      it 'generates TypeScript types and Zod schemas for types from introspection' do
        # Should generate TypeScript types and schemas for all registered types that appear in output
        introspect[:types].each do |type_name, type_def|
          schema_name = Apiwork::Transform::Case.string(type_name, :camelize_upper)

          # Skip types that aren't in the output (e.g., base types that aren't used)
          next unless output.include?("export const #{schema_name}Schema")

          # Check if this is a union type (has :type => :union at root level)
          is_union = type_def.is_a?(Hash) && type_def[:type] == :union

          # Detect if type is recursive by checking if it references itself
          is_recursive = !is_union && detect_recursive_type(type_name, type_def)

          if is_union
            # Union types should have TypeScript type alias (not interface)
            expect(output).to include("export type #{schema_name} ="),
                              "Missing type alias for union type #{type_name}"
            # Union types should use z.union()
            expect(output).to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.union"),
                              "Union type #{type_name} should use z.union"
          else
            # Object types should have a TypeScript interface declaration
            expect(output).to include("export interface #{schema_name}"),
                              "Missing interface for #{type_name}"

            # All types should have a Zod schema with z.ZodType annotation
            expect(output).to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}>"),
                              "Missing schema for #{type_name}"

            if is_recursive
              # Recursive types use z.lazy()
              expect(output).to include('z.lazy'), "Recursive type #{type_name} should use z.lazy"
            else
              # Non-recursive types use z.object()
              expect(output).to include('z.object'), "Non-recursive type #{type_name} should use z.object"
            end
          end
        end
      end

      it 'uses z.lazy for recursive filter types' do
        # Filter types with _and, _or, _not should use z.lazy
        filter_types = introspect[:types].select { |name, _| name.to_s.include?('filter') }
        expect(filter_types).not_to be_empty

        filter_types.each do |type_name, type_def|
          next unless detect_recursive_type(type_name, type_def)

          schema_name = Apiwork::Transform::Case.string(type_name, :camelize_upper)

          # Should have TypeScript interface declaration (not type alias)
          expect(output).to include("export interface #{schema_name}")

          # Should use z.lazy wrapper with z.ZodType annotation
          expect(output).to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.lazy")

          # Should reference itself in _and, _or, _not
          expect(output).to include("z.array(#{schema_name}Schema)") if type_def[:_and]
          expect(output).to include("#{schema_name}Schema.optional()") if type_def[:_not]
        end
      end
    end

    describe 'enum schemas' do
      it 'generates enum value and filter schemas for all registered enums' do
        introspect[:enums].each_key do |enum_name|
          schema_name = Apiwork::Transform::Case.string(enum_name, :camelize_upper)
          # Should have TypeScript type declarations
          expect(output).to include("export type #{schema_name} =")
          expect(output).to include("export type #{schema_name}Filter =")
          # Should have Zod schemas with type annotations
          expect(output).to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.enum")
          expect(output).to include("export const #{schema_name}FilterSchema: z.ZodType<#{schema_name}Filter> = z.union")
        end
      end
    end

    describe 'type mappings' do
      it 'maps primitive types correctly' do
        # The generator should handle various primitive types
        # Check for Zod type constructors
        expect(output).to include('z.string')
        expect(output).to include('z.number')
        expect(output).to include('z.object')

        # All types should have TypeScript interface definitions
        # which may include "| undefined" for optional fields
        types_count = introspect[:types].count
        expect(output).to include('export interface') if types_count.positive?
      end
    end

    describe 'topological sorting and type ordering' do
      # Extract schema declarations in order from the generated output
      let(:schema_order) do
        output.scan(/export const (\w+)Schema: z\.ZodType/).flatten
      end

      # Helper to get schema index in declaration order
      def schema_index(type_name)
        schema_name = Apiwork::Transform::Case.string(type_name, :camelize_upper)
        schema_order.index(schema_name)
      end

      # Helper to verify type_a comes before type_b
      def expect_before(type_a, type_b, reason = nil)
        idx_a = schema_index(type_a)
        idx_b = schema_index(type_b)

        expect(idx_a).not_to be_nil, "#{type_a} schema should exist in output"
        expect(idx_b).not_to be_nil, "#{type_b} schema should exist in output"
        expect(idx_a).to be < idx_b,
                         reason || "#{type_a} (##{idx_a + 1}) should come before #{type_b} (##{idx_b + 1})"
      end

      it 'places all dependencies before their dependents in topological order' do
        # Verify each type comes after its dependencies (excluding self-references)
        introspect[:types].each do |type_name, type_def|
          schema_idx = schema_index(type_name)
          next unless schema_idx # Skip types not in output

          # Extract dependencies for this type (excluding self-references for recursive types)
          dependencies = extract_type_references(type_def).reject { |dep| dep == type_name }

          dependencies.each do |dep|
            dep_idx = schema_index(dep)
            next unless dep_idx # Skip if dependency not in output

            # Check if this is a circular dependency (both types depend on each other)
            dep_def = introspect[:types][dep]
            dep_dependencies = dep_def ? extract_type_references(dep_def).reject { |d| d == dep } : []
            is_circular = dep_dependencies.include?(type_name)

            # For circular dependencies, order doesn't matter (both use z.lazy())
            next if is_circular

            expect(dep_idx).to be < schema_idx,
                               "#{dep} (##{dep_idx + 1}) should come before #{type_name} (##{schema_idx + 1})"
          end
        end
      end

      it 'places date_filter_between before date_filter' do
        expect_before(:date_filter_between, :date_filter,
                      'DateFilterBetween must be declared before DateFilter uses it')
      end

      it 'places integer_filter_between before integer_filter' do
        expect_before(:integer_filter_between, :integer_filter,
                      'IntegerFilterBetween must be declared before IntegerFilter uses it')
      end

      it 'places all primitive filters before post_filter' do
        primitive_filters = %i[string_filter integer_filter boolean_filter datetime_filter]

        primitive_filters.each do |filter|
          expect_before(filter, :post_filter,
                        "#{filter} must be declared before PostFilter references it")
        end
      end

      it 'handles recursive types without breaking dependency order' do
        # Find all recursive types (types that reference themselves)
        recursive_types = introspect[:types].select { |name, type_def| detect_recursive_type(name, type_def) }

        expect(recursive_types).not_to be_empty, 'Should have recursive types to test'

        recursive_types.each do |type_name, type_def|
          schema_name = Apiwork::Transform::Case.string(type_name, :camelize_upper)

          # Verify recursive types use z.lazy()
          expect(output).to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.lazy"),
                            "#{type_name} should use z.lazy() for self-reference"

          # Verify non-self dependencies still come before this type
          dependencies = extract_type_references(type_def).reject { |dep| dep == type_name }
          type_idx = schema_index(type_name)

          dependencies.each do |dep|
            dep_idx = schema_index(dep)
            next unless dep_idx # Skip if dependency not in output

            expect(dep_idx).to be < type_idx,
                               "#{dep} should come before recursive type #{type_name}"
          end
        end
      end
    end
  end

  describe '.file_extension' do
    it 'returns .ts' do
      expect(described_class.file_extension).to eq('.ts')
    end
  end

  describe '.generator_name' do
    it 'returns :zod' do
      expect(described_class.generator_name).to eq(:zod)
    end
  end

  describe '.content_type' do
    it 'returns text/plain; charset=utf-8' do
      expect(described_class.content_type).to eq('text/plain; charset=utf-8')
    end
  end

  describe 'integration with real API' do
    it 'produces valid Zod schemas without errors' do
      expect { generator.generate }.not_to raise_error
    end

    it 'generates non-empty output' do
      output = generator.generate
      expect(output.length).to be > 100
    end

    it 'has valid TypeScript structure' do
      output = generator.generate

      # Should have proper imports
      expect(output.lines.first).to include('import')

      # Should have exports
      expect(output).to match(/export (const|type)/)

      # Should have proper Zod schema syntax
      expect(output).to include('z.object')
      expect(output).to include('z.enum') | include('z.string') | include('z.number')
    end
  end
end
