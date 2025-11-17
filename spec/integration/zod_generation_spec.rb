# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod Generation for Associations', type: :integration do
  # Force reload of API configuration before tests
  before(:all) do
    load Rails.root.join('config/apis/v1.rb')
  end

  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Generator::Zod.new(path) }
  # Use let! to generate output once and share across all tests in this group
  let!(:output) { generator.generate }

  describe 'Post output schema with has_many :comments association' do
    it 'generates comment association as CommentSchema array, not z.string()' do
      # Find the post type definition in output
      expect(output).to include('export const PostSchema')

      # Extract just the PostSchema definition
      post_schema_match = output.match(/export const PostSchema\b.*?\n\}\);/m)
      expect(post_schema_match).not_to be_nil, 'PostSchema definition not found'
      post_schema = post_schema_match[0]

      # Should reference CommentSchema for comments field
      expect(post_schema).to match(/comments:.*CommentSchema/)
      expect(post_schema).not_to match(/comments:.*z\.string\(\)/)
    end
  end

  describe 'Comment output schema with belongs_to :post association' do
    it 'generates post association as PostSchema, not z.string()' do
      expect(output).to include('export const CommentSchema')

      # Extract just the CommentSchema definition
      comment_schema_match = output.match(/export const CommentSchema\b.*?\n\}\);/m)
      expect(comment_schema_match).not_to be_nil, 'CommentSchema definition not found'
      comment_schema = comment_schema_match[0]

      # Should reference PostSchema for post field
      expect(comment_schema).to match(/post:.*PostSchema/)
      expect(comment_schema).not_to match(/post:.*z\.string\(\)/)
    end
  end

  describe 'Reply output schema (association-only schema)' do
    it 'generates ReplySchema even though Reply has no routes' do
      # This verifies our earlier introspection fix works for Zod too
      expect(output).to include('export const ReplySchema')
      expect(output).to match(/ReplySchema.*z\.object/)
    end
  end

  describe 'Comment output schema with has_many :replies association' do
    it 'generates replies association as ReplySchema array, not z.string()' do
      expect(output).to include('export const CommentSchema')

      # Extract just the CommentSchema definition
      comment_schema_match = output.match(/export const CommentSchema\b.*?\n\}\);/m)
      expect(comment_schema_match).not_to be_nil, 'CommentSchema definition not found'
      comment_schema = comment_schema_match[0]

      # Should reference ReplySchema for replies field
      expect(comment_schema).to match(/replies:.*ReplySchema/)
      expect(comment_schema).not_to match(/replies:.*z\.string\(\)/)
    end
  end

  describe 'nested_payload types for writable associations' do
    it 'generates separate create and update payload schemas' do
      # Comment has writable replies association, so it should have nested payload types
      expect(output).to include('export const CommentNestedCreatePayloadSchema')
      expect(output).to include('export const CommentNestedUpdatePayloadSchema')
      expect(output).to include('export const CommentNestedPayloadSchema')
    end

    it 'generates nested_payload union that references create and update schemas' do
      # Extract the union definition
      union_match = output.match(/export const CommentNestedPayloadSchema.*?;/m)
      expect(union_match).not_to be_nil, 'CommentNestedPayloadSchema union not found'
      union_def = union_match[0]

      # Should reference the separate create/update schemas, not z.string()
      expect(union_def).to match(/CommentNestedCreatePayloadSchema/)
      expect(union_def).to match(/CommentNestedUpdatePayloadSchema/)
      expect(union_def).not_to match(/z\.string\(\)/)

      # Should use z.discriminatedUnion with '_type' discriminator field
      expect(union_def).to match(/z\.discriminatedUnion\('_type', \[/)
    end

    it 'generates nested_payload types in correct order (create, update, then union)' do
      # Find positions of each schema in the output
      create_pos = output.index('export const CommentNestedCreatePayloadSchema')
      update_pos = output.index('export const CommentNestedUpdatePayloadSchema')
      union_pos = output.index('export const CommentNestedPayloadSchema')

      expect(create_pos).not_to be_nil, 'CommentNestedCreatePayloadSchema not found'
      expect(update_pos).not_to be_nil, 'CommentNestedUpdatePayloadSchema not found'
      expect(union_pos).not_to be_nil, 'CommentNestedPayloadSchema not found'

      # Verify order: create < update < union
      expect(create_pos).to be < update_pos,
                            "Create payload should come before update payload (create: #{create_pos}, update: #{update_pos})"
      expect(update_pos).to be < union_pos,
                            "Update payload should come before union (update: #{update_pos}, union: #{union_pos})"
    end

    it 'generates _type discriminator field as required (not optional)' do
      # Extract the create payload schema
      create_match = output.match(/export const CommentNestedCreatePayloadSchema.*?z\.object\(\{.*?\}\);/m)
      expect(create_match).not_to be_nil, 'CommentNestedCreatePayloadSchema not found'
      create_schema = create_match[0]

      # Extract the update payload schema
      update_match = output.match(/export const CommentNestedUpdatePayloadSchema.*?z\.object\(\{.*?\}\);/m)
      expect(update_match).not_to be_nil, 'CommentNestedUpdatePayloadSchema not found'
      update_schema = update_match[0]

      # _type should be z.literal('create') without .optional() in create schema
      expect(create_schema).to match(/_type:\s*z\.literal\('create'\)[,\s}]/)
      expect(create_schema).not_to match(/_type:\s*z\.literal\('create'\)\.optional\(\)/)

      # _type should be z.literal('update') without .optional() in update schema
      expect(update_schema).to match(/_type:\s*z\.literal\('update'\)[,\s}]/)
      expect(update_schema).not_to match(/_type:\s*z\.literal\('update'\)\.optional\(\)/)
    end

    it 'generates non-recursive schemas without z.ZodType annotation for better type inference' do
      # Extract the create payload schema (full line up to =)
      create_match = output.match(/export const CommentNestedCreatePayloadSchema[^=]*=/m)
      expect(create_match).not_to be_nil, 'CommentNestedCreatePayloadSchema declaration not found'
      create_declaration = create_match[0]

      # Extract the update payload schema (full line up to =)
      update_match = output.match(/export const CommentNestedUpdatePayloadSchema[^=]*=/m)
      expect(update_match).not_to be_nil, 'CommentNestedUpdatePayloadSchema declaration not found'
      update_declaration = update_match[0]

      # Non-recursive schemas should NOT have z.ZodType annotation
      # Type annotation only needed for z.lazy (recursive types)
      expect(create_declaration).not_to match(/z\.ZodType</)
      expect(update_declaration).not_to match(/z\.ZodType</)

      # Should just be: export const ...Schema = (without type annotation)
      expect(create_declaration).to match(/export const CommentNestedCreatePayloadSchema =/)
      expect(update_declaration).to match(/export const CommentNestedUpdatePayloadSchema =/)
    end
  end

  describe 'Enum filter Zod generation (end-to-end)' do
    let(:introspection) { Apiwork.introspect(path) }

    it 'generates complete enum filter chain: enum → filter type → Zod schema' do
      # AccountSchema has status attribute (enum)
      # -> account_status enum is generated
      # -> account_status_filter type is auto-generated
      # -> AccountStatusFilterSchema is generated in Zod

      # 1. Enum exists in introspection
      expect(introspection[:enums]).to have_key(:account_status)
      expect(introspection[:enums][:account_status]).to match_array(%w[active inactive archived])

      # 2. Filter type exists in introspection
      expect(introspection[:types]).to have_key(:account_status_filter)
      filter_type = introspection[:types][:account_status_filter]
      expect(filter_type[:type]).to eq(:union)
      expect(filter_type[:variants].size).to eq(2)

      # 3. Zod schemas are generated correctly
      expect(output).to include('export const AccountStatusSchema')
      expect(output).to include('export const AccountStatusFilterSchema')

      # 4. Verify the filter schema uses enum schema references
      filter_schema_match = output.match(/export const AccountStatusFilterSchema = z\.union\(\[.*?\]\);/m)
      expect(filter_schema_match).not_to be_nil, 'AccountStatusFilterSchema not found in output'
      expect(filter_schema_match[0]).to include('AccountStatusSchema')
    end

    it 'generates correct Zod for enum filter object variant fields' do
      # The eq and in fields should reference the enum schema
      expect(output).to match(/eq:\s*AccountStatusSchema/)
      expect(output).to match(/in:\s*z\.array\(AccountStatusSchema\)/)
    end

    it 'does NOT generate primitive filter types for enum attributes' do
      # If account_status is an enum, should NOT generate StringFilterSchema for it

      # The output should have AccountStatusFilterSchema (enum-specific)
      expect(output).to include('export const AccountStatusFilterSchema')

      # But should NOT have a StringFilterSchema being used for account_status
      # (StringFilterSchema is for primitive string fields, not enum fields)

      # Check that the account_status filter is the enum-specific one
      filter_match = output.match(/export const AccountStatusFilterSchema = z\.union\(\[(.*?)\]\);/m)
      expect(filter_match).not_to be_nil
      filter_def = filter_match[1]

      # Should reference AccountStatusSchema, not z.string()
      expect(filter_def).to include('AccountStatusSchema')
      expect(filter_def).not_to include('z.string()')
    end

    it 'handles both global and schema-scoped enum filters' do
      # Global enums (post_status)
      expect(output).to include('export const PostStatusSchema')
      expect(output).to include('export const PostStatusFilterSchema')

      # Schema-scoped enums (account_status)
      expect(output).to include('export const AccountStatusSchema')
      expect(output).to include('export const AccountStatusFilterSchema')

      # Both should be properly generated as union types with enum references
      %w[PostStatus AccountStatus].each do |enum_name|
        filter_schema_match = output.match(/export const #{enum_name}FilterSchema = z\.union\(\[.*?\]\);/m)
        expect(filter_schema_match).not_to be_nil, "#{enum_name}FilterSchema not properly generated"
      end
    end

    it 'maintains correct topological order: enum schemas before filter schemas' do
      # Enum schemas must come before their filter schemas in the output
      post_status_pos = output.index('export const PostStatusSchema')
      post_status_filter_pos = output.index('export const PostStatusFilterSchema')

      account_status_pos = output.index('export const AccountStatusSchema')
      account_status_filter_pos = output.index('export const AccountStatusFilterSchema')

      expect(post_status_pos).to be < post_status_filter_pos,
                                 'PostStatusSchema should come before PostStatusFilterSchema'
      expect(account_status_pos).to be < account_status_filter_pos,
                                    'AccountStatusSchema should come before AccountStatusFilterSchema'
    end

    it 'generates filter variant with correct schema reference types' do
      # Extract AccountStatusFilterSchema definition
      filter_match = output.match(/export const AccountStatusFilterSchema = z\.union\(\[(.*?)\]\);/m)
      expect(filter_match).not_to be_nil
      filter_def = filter_match[1]

      # First variant: AccountStatusSchema (the enum itself)
      lines = filter_def.split("\n")
      first_variant = lines.detect do |line|
        line.include?('AccountStatusSchema') && !line.include?('eq:') && !line.include?('in:')
      end
      expect(first_variant).to be_present, 'First variant should be AccountStatusSchema'

      # Second variant should be z.object with eq and in
      expect(filter_def).to match(/z\.object\(\s*\{/)
      expect(filter_def).to match(/eq:\s*AccountStatusSchema/)
      expect(filter_def).to match(/in:\s*z\.array\(AccountStatusSchema\)/)
    end

    it 'generates enum filter schemas without type annotations (non-recursive)' do
      # Enum and enum filter schemas are not recursive, so no type annotations

      # Extract AccountStatusSchema declaration
      enum_match = output.match(/export const AccountStatusSchema[^=]*=/m)
      expect(enum_match).not_to be_nil, 'AccountStatusSchema declaration not found'
      enum_declaration = enum_match[0]

      # Extract AccountStatusFilterSchema declaration
      filter_match = output.match(/export const AccountStatusFilterSchema[^=]*=/m)
      expect(filter_match).not_to be_nil, 'AccountStatusFilterSchema declaration not found'
      filter_declaration = filter_match[0]

      # Neither should have z.ZodType annotation
      expect(enum_declaration).not_to match(/z\.ZodType</)
      expect(filter_declaration).not_to match(/z\.ZodType</)

      # Should just be: export const ...Schema = (without type annotation)
      # Check that z.enum or z.union appears in the output (may be on next line)
      expect(output).to include('export const AccountStatusSchema = z.enum')
      expect(output).to include('export const AccountStatusFilterSchema = z.union')
    end

    it 'uses enum schema references in union variants with enum field' do
      # Critical test: union variants with { type: "string", enum: "account_status" }
      # should generate AccountStatusSchema, not z.string()

      # Find all filter types that might have enum variants
      introspection[:types].each do |type_name, type_def|
        next unless type_def[:type] == :union
        next unless type_def[:variants].any? { |v| v.is_a?(Hash) && v[:enum] }

        # Check that the Zod output references enum schemas, not z.string()
        schema_name = type_name.to_s.camelize(:upper)
        next unless output.include?("export const #{schema_name}Schema")

        union_match = output.match(/export const #{schema_name}Schema = z\.union\(\[(.*?)\]\);/m)
        next unless union_match

        union_def = union_match[1]

        # Any variant with enum should reference the enum schema
        type_def[:variants].each do |variant|
          next unless variant.is_a?(Hash) && variant[:enum]

          enum_schema_name = variant[:enum].to_s.camelize(:upper)
          expect(union_def).to include("#{enum_schema_name}Schema"),
                               "Union #{type_name} should reference #{enum_schema_name}Schema for enum variant"
          expect(union_def).not_to include('z.string()'),
                                   "Union #{type_name} should not use z.string() for enum variants"
        end
      end
    end

    it 'verifies AccountStatusFilterSchema first variant is NOT z.string()' do
      # This is the most critical test - the bug we fixed
      # The first variant should be AccountStatusSchema, not z.string()

      filter_match = output.match(/export const AccountStatusFilterSchema = z\.union\(\[\s*(.*?)\s*,/m)
      expect(filter_match).not_to be_nil, 'Could not extract first variant'
      first_variant = filter_match[1].strip

      # First variant should be the enum schema reference
      expect(first_variant).to eq('AccountStatusSchema'),
                               "First variant should be 'AccountStatusSchema', got '#{first_variant}'"
      expect(first_variant).not_to eq('z.string()'),
                                   'First variant should NOT be z.string()'
    end
  end
end
