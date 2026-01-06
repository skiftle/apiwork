# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript Generation', type: :integration do
  before(:all) do
    Apiwork::API.reset!
    Apiwork::ErrorCode.reset!
    load Rails.root.join('config/apis/v1.rb')
  end

  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  describe 'TypeScript output format' do
    it 'generates valid TypeScript type declarations' do
      expect(output).to be_a(String)
      expect(output).to include('export')
    end

    it 'generates interface declarations' do
      expect(output).to include('export interface')
    end

    it 'generates type declarations for enums' do
      expect(output).to match(/export type \w+ = /)
    end
  end

  describe 'Resource types' do
    it 'generates Post interface' do
      expect(output).to include('export interface Post')
    end

    it 'generates Comment interface' do
      expect(output).to include('export interface Comment')
    end

    it 'generates interfaces for nested resources' do
      expect(output).to include('export interface Reply')
    end
  end

  describe 'Property types' do
    it 'generates string properties with string type' do
      post_interface = extract_interface(output, 'Post')
      expect(post_interface).to match(/title\??: string/)
    end

    it 'generates boolean properties with boolean type' do
      post_interface = extract_interface(output, 'Post')
      expect(post_interface).to match(/published\??: boolean/)
    end

    it 'generates datetime properties with string type' do
      post_interface = extract_interface(output, 'Post')
      expect(post_interface).to match(/created_at\??: string/)
    end

    it 'generates optional properties correctly' do
      post_interface = extract_interface(output, 'Post')
      expect(post_interface).to match(/\w+\?: \w+/)
    end
  end

  describe 'Association types' do
    it 'generates has_many associations as arrays' do
      post_interface = extract_interface(output, 'Post')
      expect(post_interface).to match(/comments\??: Comment\[\]/)
    end

    it 'generates belongs_to associations as single reference' do
      comment_interface = extract_interface(output, 'Comment')
      expect(comment_interface).to match(/post\??: Post/)
    end
  end

  describe 'Filter types' do
    it 'generates filter types for resources' do
      expect(output).to include('PostFilter')
    end

    it 'includes filterable attribute options' do
      filter_interface = extract_interface(output, 'PostFilter')
      expect(filter_interface).to match(/title\??: /)
    end
  end

  describe 'Sort types' do
    it 'generates sort types for resources' do
      expect(output).to include('PostSort')
    end
  end

  describe 'Payload types' do
    it 'generates create payload types' do
      expect(output).to include('PostCreatePayload')
    end

    it 'generates update payload types' do
      expect(output).to include('PostUpdatePayload')
    end

    it 'includes writable attributes in payload' do
      create_payload = extract_interface(output, 'PostCreatePayload')
      expect(create_payload).to match(/title\??: string/)
    end
  end

  describe 'Request/Response types' do
    it 'generates request types for actions' do
      expect(output).to match(/PostsIndexRequest/)
    end

    it 'generates response types for actions' do
      expect(output).to match(/PostsIndexResponse/)
    end

    it 'generates request body types for create' do
      expect(output).to match(/PostsCreateRequestBody/)
    end

    it 'generates request query types for index' do
      expect(output).to match(/PostsIndexRequestQuery/)
    end
  end

  describe 'Nested resource types' do
    it 'generates types for nested comment under post' do
      expect(output).to match(/PostsCommentsIndexRequest|PostCommentsIndexRequest/)
    end
  end

  describe 'Key transformation options' do
    context 'with camelCase transformation' do
      let(:generator) { Apiwork::Export::TypeScript.new(path, key_format: :camel) }

      it 'transforms property names to camelCase' do
        post_interface = extract_interface(output, 'Post')
        expect(post_interface).to match(/createdAt\??: string/)
      end
    end

    context 'with keep (no transformation)' do
      let(:generator) { Apiwork::Export::TypeScript.new(path, key_format: :keep) }

      it 'keeps property names unchanged' do
        post_interface = extract_interface(output, 'Post')
        expect(post_interface).to match(/created_at\??: string/)
      end
    end
  end

  describe 'TypeScript syntax validity' do
    it 'properly closes all interfaces' do
      open_braces = output.scan(/{/).count
      close_braces = output.scan(/}/).count
      expect(open_braces).to eq(close_braces)
    end

    it 'has valid export statements' do
      expect(output.lines.grep(/^export/)).to all(match(/^export (interface|type|const) \w+/))
    end
  end

  private

  def extract_interface(output, name)
    pattern = /export interface #{name}\s*\{[^}]*\}/m
    match = output.match(pattern)
    match ? match[0] : ''
  end
end
