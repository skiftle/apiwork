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
end
