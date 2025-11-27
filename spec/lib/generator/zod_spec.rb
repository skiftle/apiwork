# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Generator::Zod do
  before do
    Apiwork::API.reset!
    Apiwork::Descriptor.reset!
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

    # Handle the new structure: for object types, fields are under :shape
    # For union types, structure is { type: :union, variants: [...] }
    if definition[:type] == :object && definition[:shape].is_a?(Hash)
      # Object type - iterate over fields in :shape
      definition[:shape].each_value do |param|
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
            refs.concat(extract_type_references(variant)) if variant[:shape].is_a?(Hash)
          end
        end

        # Recursively check nested shapes
        refs.concat(extract_type_references(param)) if param[:shape].is_a?(Hash)
      end
    elsif definition[:type] == :union && definition[:variants].is_a?(Array)
      # Union type - check variants
      definition[:variants].each do |variant|
        next unless variant.is_a?(Hash)

        refs << variant[:type] if variant[:type].is_a?(Symbol) && !primitive_type?(variant[:type])
        refs << variant[:of] if variant[:of].is_a?(Symbol) && !primitive_type?(variant[:of])

        # Recursively check nested definitions
        refs.concat(extract_type_references(variant)) if variant[:shape].is_a?(Hash) || variant[:variants].is_a?(Array)
      end
    else
      # Fallback: old behavior for other structures
      definition.each_value do |param|
        next unless param.is_a?(Hash)

        refs << param[:type] if param[:type].is_a?(Symbol) && !primitive_type?(param[:type])
        refs << param[:of] if param[:of].is_a?(Symbol) && !primitive_type?(param[:of])

        if param[:variants].is_a?(Array)
          param[:variants].each do |variant|
            next unless variant.is_a?(Hash)

            refs << variant[:type] if variant[:type].is_a?(Symbol) && !primitive_type?(variant[:type])
            refs << variant[:of] if variant[:of].is_a?(Symbol) && !primitive_type?(variant[:of])

            refs.concat(extract_type_references(variant)) if variant[:shape].is_a?(Hash)
          end
        end

        refs.concat(extract_type_references(param)) if param[:shape].is_a?(Hash)
      end
    end

    refs.uniq
  end

  # Helper method to check if a type is primitive
  def primitive_type?(type)
    %i[string integer boolean datetime date uuid object array decimal float literal union enum].include?(type)
  end

  describe '#generate' do
    # Generate output lazily on first access (cached within each test)
    let(:output) { generator.generate }

    it 'generates valid TypeScript code' do
      expect(output).to be_a(String)
      expect(output).to include("import { z } from 'zod';")
    end

    describe 'filter and utility schemas from introspect' do
      it 'includes SortDirectionSchema from introspect enums' do
        expect(output).to include("export type SortDirection = 'asc' | 'desc'")
        expect(output).to include('export const SortDirectionSchema = z.enum')
        expect(output).to match(/SortDirectionSchema.*asc.*desc/m)
      end

      it 'includes StringFilterSchema from introspect types' do
        expect(output).to include('export interface StringFilter')
        expect(output).to include('export const StringFilterSchema = z.object')
      end

      it 'includes IntegerFilterSchema from introspect types' do
        expect(output).to include('export interface IntegerFilter')
        expect(output).to include('export const IntegerFilterSchema = z.object')
      end

      it 'includes DatetimeFilterSchema from introspect types' do
        expect(output).to include('export interface DatetimeFilter')
        expect(output).to include('export const DatetimeFilterSchema = z.object')
      end

      # DateFilter and UuidFilter are not included because no schema uses date or uuid types
      # Only types actually used by schemas are registered with lazy loading

      it 'includes NullableBooleanFilterSchema from introspect types' do
        expect(output).to include('export interface NullableBooleanFilter')
        expect(output).to include('export const NullableBooleanFilterSchema = z.object')
      end

      it 'includes schema-specific page schemas' do
        # Schema-specific page types like UserPage, PostPage, etc.
        expect(output).to include('export interface UserPage')
        expect(output).to include('export const UserPageSchema = z.object')
        expect(output).to include('export interface PostPage')
        expect(output).to include('export const PostPageSchema = z.object')
      end
    end

    describe 'type schemas' do
      it 'generates TypeScript types and Zod schemas for types from introspection' do
        # Should generate TypeScript types and schemas for all registered types that appear in output
        introspect[:types].each do |type_name, type_def|
          schema_name = type_name.to_s.camelize(:upper)

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
            # Union types should use z.union() or z.discriminatedUnion() without type annotation
            union_or_discriminated = output.include?("export const #{schema_name}Schema = z.union") ||
                                     output.include?("export const #{schema_name}Schema = z.discriminatedUnion")
            expect(union_or_discriminated).to be(true),
                                              "Union type #{type_name} should use z.union or z.discriminatedUnion"
          else
            # Object types should have either interface or type declaration
            # Empty objects use type alias, non-empty use interface
            expect(output).to match(/export (interface|type) #{schema_name}( =|(\s*\{))/),
                              "Missing interface or type declaration for #{type_name}"

            # Type annotation only for recursive types (z.lazy requires it)
            if is_recursive
              # Recursive types need explicit type annotation
              expect(output).to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}>"),
                                "Recursive type #{type_name} should have z.ZodType annotation"
            else
              # Non-recursive types should NOT have type annotation (better inference)
              expect(output).to include("export const #{schema_name}Schema ="),
                                "Missing schema declaration for #{type_name}"
              expect(output).not_to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}>"),
                                    "Non-recursive type #{type_name} should not have z.ZodType annotation"
            end

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

          schema_name = type_name.to_s.camelize(:upper)

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
          schema_name = enum_name.to_s.camelize(:upper)
          # Should have TypeScript type declarations
          expect(output).to include("export type #{schema_name} =")
          expect(output).to include("export type #{schema_name}Filter =")
          # Should have Zod schemas without type annotations (non-recursive)
          expect(output).to include("export const #{schema_name}Schema = z.enum")
          expect(output).to include("export const #{schema_name}FilterSchema = z.union")
        end
      end

      it 'generates enum filter schemas with correct enum schema references' do
        # AccountStatusFilterSchema should reference AccountStatusSchema, not z.string()
        expect(output).to include('export const AccountStatusFilterSchema = z.union([')

        # Extract the AccountStatusFilterSchema definition
        filter_match = output.match(/export const AccountStatusFilterSchema = z\.union\(\[.*?\]\);/m)
        expect(filter_match).not_to be_nil, 'AccountStatusFilterSchema not found'
        filter_schema = filter_match[0]

        # First variant should be the enum schema itself
        expect(filter_schema).to include('AccountStatusSchema')
        # Second variant should be an object with eq and in fields that reference the enum schema
        expect(filter_schema).to match(/eq:\s*AccountStatusSchema/)
        expect(filter_schema).to match(/in:\s*z\.array\(AccountStatusSchema\)/)
        # Should NOT use z.string() for enum references
        expect(filter_schema).not_to match(/eq:\s*z\.string\(\)/)
        expect(filter_schema).not_to match(/in:\s*z\.array\(z\.string\(\)\)/)
      end

      it 'generates enum schemas without type annotations (non-recursive)' do
        # Enum schemas are never recursive, so they should not have type annotations
        introspect[:enums].each_key do |enum_name|
          schema_name = enum_name.to_s.camelize(:upper)
          # Should NOT have type annotation
          expect(output).not_to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}>"),
                                "Enum schema #{enum_name} should not have z.ZodType annotation"
          # Should have simple declaration
          expect(output).to include("export const #{schema_name}Schema = z.enum")
        end
      end

      it 'generates enum filter schemas without type annotations (non-recursive)' do
        # Enum filter schemas (union of enum + filter object) are not recursive
        introspect[:enums].each_key do |enum_name|
          schema_name = "#{enum_name.to_s.camelize(:upper)}Filter"
          # Should NOT have type annotation
          expect(output).not_to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}>"),
                                "Enum filter schema #{enum_name}_filter should not have z.ZodType annotation"
          # Should have simple union declaration
          expect(output).to include("export const #{schema_name}Schema = z.union")
        end
      end

      it 'generates AccountStatusFilterSchema as union of enum and filter object' do
        expect(output).to include('export const AccountStatusFilterSchema = z.union([')

        # Extract the filter schema definition
        filter_match = output.match(/export const AccountStatusFilterSchema = z\.union\(\[(.*?)\]\);/m)
        expect(filter_match).not_to be_nil
        filter_def = filter_match[1]

        # First variant: AccountStatusSchema (the enum itself)
        lines = filter_def.split("\n")
        first_variant = lines.detect { |line| line.strip.start_with?('AccountStatusSchema') }
        expect(first_variant).to be_present, 'First variant should be AccountStatusSchema'

        # Second variant should be z.object with eq and in
        expect(filter_def).to match(/z\.object\(\s*\{/)
        expect(filter_def).to match(/eq:\s*AccountStatusSchema/)
        expect(filter_def).to match(/in:\s*z\.array\(AccountStatusSchema\)/)
      end

      it 'does NOT generate z.string() for enum filter variants' do
        # Critical: enum filter variants should reference enum schemas, not z.string()
        filter_match = output.match(/export const AccountStatusFilterSchema = z\.union\(\[(.*?)\]\);/m)
        expect(filter_match).not_to be_nil
        filter_def = filter_match[1]

        # Should NOT contain z.string() anywhere in the filter definition
        expect(filter_def).not_to include('z.string()')
      end

      it 'maintains topological order: enum schemas before filter schemas' do
        # Enum schemas must come before their filter schemas in the output
        introspect[:enums].each_key do |enum_name|
          enum_schema_name = enum_name.to_s.camelize(:upper)
          filter_schema_name = "#{enum_schema_name}Filter"

          enum_pos = output.index("export const #{enum_schema_name}Schema")
          filter_pos = output.index("export const #{filter_schema_name}Schema")

          next unless enum_pos && filter_pos # Skip if either not in output

          expect(enum_pos).to be < filter_pos,
                              "#{enum_schema_name}Schema should come before #{filter_schema_name}Schema"
        end
      end
    end

    describe 'union variants with enum field' do
      it 'generates enum schema reference for union variants with enum type' do
        # This tests the critical fix: { type: "string", enum: "account_status" }
        # Should generate AccountStatusSchema not z.string()

        introspect[:types].each do |type_name, type_def|
          next unless type_def[:type] == :union

          type_def[:variants].each do |variant|
            next unless variant.is_a?(Hash)
            next unless variant[:enum]

            # When a variant has an enum field, it should reference the enum schema
            variant_enum = variant[:enum].to_s.camelize(:upper)
            expect(output).to include("#{variant_enum}Schema"),
                              "Variant with enum field should reference #{variant_enum}Schema"

            # The variant should NOT be z.string() even if type is :string
            # Check in the context of the union that contains this variant
            schema_name = type_name.to_s.camelize(:upper)
            next unless output.include?("export const #{schema_name}Schema")

            # This variant in the union should use the enum schema, not z.string()
            union_match = output.match(/export const #{schema_name}Schema = z\.union\(\[(.*?)\]\);/m)
            next unless union_match

            union_definition = union_match[1]
            # If this union has the enum variant, it should reference the schema
            expect(union_definition).to include("#{variant_enum}Schema") if union_definition.include?(variant_enum.underscore)
          end
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
        output.scan(/export const (\w+)Schema\b/).flatten
      end

      # Helper to get schema index in declaration order
      def schema_index(type_name)
        schema_name = type_name.to_s.camelize(:upper)
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

            # Check if this is a circular dependency (both types depend on each other directly or indirectly)
            dep_def = introspect[:types][dep]
            dep_dependencies = dep_def ? extract_type_references(dep_def).reject { |d| d == dep } : []
            is_direct_circular = dep_dependencies.include?(type_name)

            # Also check for indirect circularity (e.g., Article → Comment → Post → Comment)
            # If dependency's dependencies also depend back on us (directly or through chain), skip
            is_indirect_circular = dep_dependencies.any? do |transitive_dep|
              transitive_def = introspect[:types][transitive_dep]
              next false unless transitive_def

              transitive_deps = extract_type_references(transitive_def).reject { |d| d == transitive_dep }
              transitive_deps.include?(type_name) || transitive_deps.include?(dep)
            end

            # For circular dependencies, order doesn't matter (both use z.lazy())
            next if is_direct_circular || is_indirect_circular

            expect(dep_idx).to be < schema_idx,
                               "#{dep} (##{dep_idx + 1}) should come before #{type_name} (##{schema_idx + 1})"
          end
        end
      end

      # date_filter is not registered because no schema uses date type
      # Only types actually used by schemas are registered with lazy loading

      it 'places datetime_filter_between before datetime_filter' do
        expect_before(:datetime_filter_between, :datetime_filter,
                      'DatetimeFilterBetween must be declared before DatetimeFilter uses it')
      end

      it 'places integer_filter_between before integer_filter' do
        expect_before(:integer_filter_between, :integer_filter,
                      'IntegerFilterBetween must be declared before IntegerFilter uses it')
      end

      it 'places all primitive filters before post_filter' do
        primitive_filters = %i[string_filter integer_filter nullable_boolean_filter datetime_filter]

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
          schema_name = type_name.to_s.camelize(:upper)

          # Verify recursive types use z.lazy()
          expect(output).to include("export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.lazy"),
                            "#{type_name} should use z.lazy() for self-reference"

          # Verify non-self dependencies still come before this type
          dependencies = extract_type_references(type_def).reject { |dep| dep == type_name }
          type_idx = schema_index(type_name)

          dependencies.each do |dep|
            dep_idx = schema_index(dep)
            next unless dep_idx # Skip if dependency not in output

            # Check for circular dependencies (like comment_filter ↔ post_filter)
            dep_def = introspect[:types][dep]
            dep_dependencies = dep_def ? extract_type_references(dep_def).reject { |d| d == dep } : []
            is_direct_circular = dep_dependencies.include?(type_name)

            # Also check for indirect circularity
            is_indirect_circular = dep_dependencies.any? do |transitive_dep|
              transitive_def = introspect[:types][transitive_dep]
              next false unless transitive_def

              transitive_deps = extract_type_references(transitive_def).reject { |d| d == transitive_dep }
              transitive_deps.include?(type_name) || transitive_deps.include?(dep)
            end

            # For circular dependencies, order doesn't matter (both use z.lazy())
            next if is_direct_circular || is_indirect_circular

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

  describe '.identifier' do
    it 'returns :zod' do
      expect(described_class.identifier).to eq(:zod)
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

  describe 'action request/response schemas' do
    # Generate output lazily on first access (cached within each test)
    let(:output) { generator.generate }

    it 'generates TypeScript types for action requests' do
      # Check for TypeScript interface/type declarations (e.g., PostsCreateRequest)
      expect(output).to match(/export interface \w+Request \{/)
    end

    it 'generates TypeScript types for action responses' do
      # Check for TypeScript type declarations (e.g., PostsCreateResponse)
      expect(output).to match(/export interface \w+Response \{/)
    end

    it 'generates separate RequestQuery schemas' do
      # Check for separate query schemas (e.g., PostsIndexRequestQuerySchema)
      expect(output).to match(/export const \w+RequestQuerySchema = z\.object/)
      expect(output).not_to match(/export const \w+RequestQuerySchema: z\.ZodType/)
    end

    it 'generates separate RequestBody schemas' do
      # Check for separate body schemas (e.g., PostsCreateRequestBodySchema)
      expect(output).to match(/export const \w+RequestBodySchema = z\.object/)
      expect(output).not_to match(/export const \w+RequestBodySchema: z\.ZodType/)
    end

    it 'generates combined Request schemas that reference query/body' do
      # Combined request schemas should reference the separate parts
      expect(output).to match(/export const \w+RequestSchema = z\.object\(\{\n  query: \w+RequestQuerySchema/)
    end

    it 'generates separate ResponseBody schemas as unions' do
      # Check for separate response body schemas (e.g., PostsIndexResponseBodySchema)
      # ResponseBody schemas should use unions with success and error variants
      expect(output).to match(/export const \w+ResponseBodySchema = z\.union/)
    end

    it 'generates combined Response schemas that wrap body' do
      # Combined response schemas should wrap the body
      expect(output).to match(/export const \w+ResponseSchema = z\.object\(\{\n  body: \w+ResponseBodySchema/)
    end

    it 'generates schemas before types (correct order)' do
      # Zod schemas should come before TypeScript types
      type_positions = output.enum_for(:scan, /export (interface|type) \w+(?:Request|Response) /).map { Regexp.last_match.begin(0) }
      schema_positions = output.enum_for(:scan, /export const \w+(?:Request|Response)Schema =/).map { Regexp.last_match.begin(0) }

      expect(type_positions).not_to be_empty
      expect(schema_positions).not_to be_empty

      # First schema should come before first type
      expect(schema_positions.min).to be < type_positions.min
    end

    it 'uses direct schema definitions without z.infer (explicit types)' do
      # Action schemas should NOT use z.infer
      expect(output).not_to match(/z\.infer<typeof \w+(?:Request|Response)Schema>/)

      # Action schemas should NOT have z.ZodType annotation (non-recursive, better inference)
      expect(output).not_to match(/: z\.ZodType<\w+(?:Request|Response)>/)
    end
  end

  describe 'unknown type mapping' do
    let(:mapper) { Apiwork::Generator::ZodMapper.new(introspection: introspect) }

    it 'maps :unknown to z.unknown()' do
      result = mapper.send(:map_primitive, { type: :unknown })
      expect(result).to eq('z.unknown()')
    end

    it 'uses z.unknown() as fallback for unmapped types' do
      result = mapper.send(:map_primitive, { type: :some_unmapped_type })
      expect(result).to eq('z.unknown()')
    end
  end

  describe 'Zod v4 format mapping' do
    let(:mapper) { Apiwork::Generator::ZodMapper.new(introspection: introspect) }

    describe 'string formats' do
      it 'maps email format to z.email()' do
        result = mapper.send(:map_primitive, { type: :string, format: :email })
        expect(result).to eq('z.email()')
      end

      it 'maps uuid format to z.uuid()' do
        result = mapper.send(:map_primitive, { type: :string, format: :uuid })
        expect(result).to eq('z.uuid()')
      end

      it 'maps url format to z.url()' do
        result = mapper.send(:map_primitive, { type: :string, format: :url })
        expect(result).to eq('z.url()')
      end

      it 'maps uri format to z.url()' do
        result = mapper.send(:map_primitive, { type: :string, format: :uri })
        expect(result).to eq('z.url()')
      end

      it 'maps ipv4 format to z.ipv4()' do
        result = mapper.send(:map_primitive, { type: :string, format: :ipv4 })
        expect(result).to eq('z.ipv4()')
      end

      it 'maps ipv6 format to z.ipv6()' do
        result = mapper.send(:map_primitive, { type: :string, format: :ipv6 })
        expect(result).to eq('z.ipv6()')
      end

      it 'maps date format to z.iso.date()' do
        result = mapper.send(:map_primitive, { type: :string, format: :date })
        expect(result).to eq('z.iso.date()')
      end

      it 'maps date_time format to z.iso.datetime()' do
        result = mapper.send(:map_primitive, { type: :string, format: :date_time })
        expect(result).to eq('z.iso.datetime()')
      end

      it 'maps password format to z.string()' do
        result = mapper.send(:map_primitive, { type: :string, format: :password })
        expect(result).to eq('z.string()')
      end

      it 'maps hostname format to z.string()' do
        result = mapper.send(:map_primitive, { type: :string, format: :hostname })
        expect(result).to eq('z.string()')
      end
    end

    describe 'integer formats' do
      it 'maps int32 format to z.number().int()' do
        result = mapper.send(:map_primitive, { type: :integer, format: :int32 })
        expect(result).to eq('z.number().int()')
      end

      it 'maps int64 format to z.number().int()' do
        result = mapper.send(:map_primitive, { type: :integer, format: :int64 })
        expect(result).to eq('z.number().int()')
      end
    end

    describe 'number formats' do
      it 'maps float format to z.number()' do
        result = mapper.send(:map_primitive, { type: :float, format: :float })
        expect(result).to eq('z.number()')
      end

      it 'maps double format to z.number()' do
        result = mapper.send(:map_primitive, { type: :float, format: :double })
        expect(result).to eq('z.number()')
      end
    end

    describe 'format overrides type' do
      it 'uses format mapping instead of type mapping when format is present' do
        # String with email format should use z.email() not z.string()
        result = mapper.send(:map_primitive, { type: :string, format: :email })
        expect(result).to eq('z.email()')
      end

      it 'falls back to type mapping when no format is specified' do
        # String without format should use z.string()
        result = mapper.send(:map_primitive, { type: :string })
        expect(result).to eq('z.string()')
      end
    end
  end
end
