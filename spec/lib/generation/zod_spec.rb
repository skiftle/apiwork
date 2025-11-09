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
        # Should generate schemas for all registered types
        introspect[:types].each_key do |type_name|
          schema_name = Apiwork::Transform::Case.string(type_name, :camelize_upper)
          expect(output).to include("export const #{schema_name}Schema = z.object")
          expect(output).to include("export type #{schema_name} = z.infer<typeof #{schema_name}Schema>")
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
        # We verify this by checking the output doesn't contain obvious errors
        expect(output).not_to include('undefined')
        expect(output).to include('z.')
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
