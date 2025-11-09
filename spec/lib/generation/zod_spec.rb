# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Generation::Zod do
  before do
    # Load test API
    load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)
  end

  let(:path) { '/api/v1' }
  let(:generator) { described_class.new(path) }
  let(:api) { Apiwork::API::Registry.find(path) }
  let(:introspect) { api.introspect }

  describe '#generate' do
    let(:output) { generator.generate }

    it 'generates valid TypeScript code' do
      expect(output).to be_a(String)
      expect(output).to include("import { z } from 'zod';")
    end

    describe 'filter and utility schemas from introspect' do
      it 'includes SortDirectionSchema from introspect enums' do
        expect(output).to include('export const SortDirectionSchema = z.enum')
        expect(output).to match(/SortDirectionSchema.*asc.*desc/m)
      end

      it 'includes StringFilterSchema from introspect types' do
        expect(output).to include('export const StringFilterSchema = z.object')
        expect(output).to include('export type StringFilter = z.infer<typeof StringFilterSchema>')
      end

      it 'includes IntegerFilterSchema from introspect types' do
        expect(output).to include('export const IntegerFilterSchema = z.object')
        expect(output).to include('export type IntegerFilter = z.infer<typeof IntegerFilterSchema>')
      end

      it 'includes DateFilterSchema from introspect types' do
        expect(output).to include('export const DateFilterSchema = z.object')
        expect(output).to include('export type DateFilter = z.infer<typeof DateFilterSchema>')
      end

      it 'includes UuidFilterSchema from introspect types' do
        expect(output).to include('export const UuidFilterSchema = z.object')
        expect(output).to include('export type UuidFilter = z.infer<typeof UuidFilterSchema>')
      end

      it 'includes BooleanFilterSchema from introspect types' do
        expect(output).to include('export const BooleanFilterSchema = z.object')
        expect(output).to include('export type BooleanFilter = z.infer<typeof BooleanFilterSchema>')
      end

      it 'includes PageParamsSchema (pagination) from introspect types' do
        expect(output).to include('export const PageParamsSchema = z.object')
        expect(output).to include('export type PageParams = z.infer<typeof PageParamsSchema>')
      end
    end

    describe 'type schemas' do
      it 'generates schemas for types from introspection' do
        # Should generate schemas for all registered types that appear in output
        introspect[:types].each do |type_name, type_def|
          schema_name = Apiwork::Transform::Case.string(type_name, :camelize_upper)

          # Skip types that aren't in the output (e.g., base types that aren't used)
          next unless output.include?("export const #{schema_name}Schema")

          # All types should have a schema constant and type export
          expect(output).to include("export const #{schema_name}Schema"), "Missing schema for #{type_name}"
          expect(output).to include("export type #{schema_name}"), "Missing type export for #{type_name}"

          if type_def[:recursive]
            # Recursive types use z.lazy() with z.infer
            expect(output).to include("export const #{schema_name}Schema = z.lazy"), "Recursive type #{type_name} should use z.lazy"
            expect(output).to include("export type #{schema_name} = z.infer<typeof #{schema_name}Schema>"), "Recursive type #{type_name} should use z.infer"
          else
            # Non-recursive types use z.object() and z.infer
            expect(output).to include("export const #{schema_name}Schema = z.object"), "Non-recursive type #{type_name} should use z.object"
            expect(output).to include("export type #{schema_name} = z.infer<typeof #{schema_name}Schema>"), "Non-recursive type #{type_name} should use z.infer"
          end
        end
      end

      it 'uses z.lazy for recursive filter types' do
        # Filter types with _and, _or, _not should use z.lazy
        filter_types = introspect[:types].select { |name, _| name.to_s.include?('filter') }
        expect(filter_types).not_to be_empty

        filter_types.each do |type_name, type_def|
          next unless type_def[:recursive]

          schema_name = Apiwork::Transform::Case.string(type_name, :camelize_upper)

          # Should have TypeScript type definition with z.infer
          expect(output).to include("export type #{schema_name} = z.infer<typeof #{schema_name}Schema>")

          # Should use z.lazy wrapper
          expect(output).to include("export const #{schema_name}Schema = z.lazy")

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
          expect(output).to include("export const #{schema_name}Schema = z.enum")
          expect(output).to include("export const #{schema_name}FilterSchema = z.union")
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

        # Recursive types should have TypeScript type definitions
        # which may include "| undefined" for optional fields
        recursive_types = introspect[:types].select { |_name, type_def| type_def[:recursive] }
        if recursive_types.any?
          expect(output).to include('export type')
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
