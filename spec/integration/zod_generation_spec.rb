# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod Generation for Associations', type: :integration do
  # Force reload of API configuration before tests
  before(:all) do
    load Rails.root.join('config/apis/v1.rb')
  end

  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Generator::Zod.new(path) }
  let(:output) { generator.generate }

  describe 'Post output schema with has_many :comments association' do
    it 'generates comment association as CommentSchema array, not z.string()' do
      # Find the post type definition in output
      expect(output).to include('export const PostSchema')

      # Extract just the PostSchema definition
      post_schema_match = output.match(/export const PostSchema:.*?\n\}\);/m)
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
      comment_schema_match = output.match(/export const CommentSchema:.*?\n\}\);/m)
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
      comment_schema_match = output.match(/export const CommentSchema:.*?\n\}\);/m)
      expect(comment_schema_match).not_to be_nil, 'CommentSchema definition not found'
      comment_schema = comment_schema_match[0]

      # Should reference ReplySchema for replies field
      expect(comment_schema).to match(/replies:.*ReplySchema/)
      expect(comment_schema).not_to match(/replies:.*z\.string\(\)/)
    end
  end
end
