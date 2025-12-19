# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Response nullable vs optional semantics' do
  before do
    Apiwork.reset!
    load File.expand_path('../dummy/config/apis/v1.rb', __dir__)
  end

  let(:api) { Apiwork::API::Registry.find('/api/v1') }
  let(:introspection) { api.introspect }
  let(:types) { introspection[:types] }

  describe 'response types' do
    it 'response attributes are always present (never optional)' do
      post_type = types[:post]
      expect(post_type).not_to be_nil

      post_shape = post_type[:shape]

      post_shape.each do |attr_name, attr_def|
        # Skip associations - they can be optional when not always included
        next if [:author, :comments, :tags, :taggings].include?(attr_name)

        expect(attr_def[:optional]).to be_falsey,
          "Response attribute :#{attr_name} should not be optional but was: #{attr_def.inspect}"
      end
    end

    it 'response attributes can be nullable' do
      user_type = types[:user]
      expect(user_type).not_to be_nil

      user_shape = user_type[:shape]

      # email should be nullable based on schema
      expect(user_shape[:email][:nullable]).to be true
    end

    it 'non-nullable response attributes are not nullable' do
      user_type = types[:user]
      user_shape = user_type[:shape]

      # name should not be nullable
      expect(user_shape[:name][:nullable]).to be_falsey
    end
  end

  describe 'request types (payloads)' do
    it 'request attributes can be optional' do
      create_payload = types[:user_create_payload] || types[:create_payload]

      if create_payload
        payload_shape = create_payload[:shape]
        optional_attrs = payload_shape.select { |_, v| v[:optional] == true }
        expect(optional_attrs).not_to be_empty
      end
    end

    it 'request attributes can be nullable' do
      create_payload = types[:user_create_payload] || types[:create_payload]

      if create_payload
        payload_shape = create_payload[:shape]
        nullable_attrs = payload_shape.select { |_, v| v[:nullable] == true }
        expect(nullable_attrs).not_to be_empty
      end
    end
  end

  describe 'Zod output reflects nullable but not optional for responses' do
    let(:zod_output) { Apiwork::Spec::Zod.generate('/api/v1') }

    it 'response schemas have nullable but not optional on fields' do
      # Parse output to verify nullable usage
      expect(zod_output).to include('.nullable()')

      # Verify responses don't have .optional() on regular fields
      # (only on associations that are not always included)
      lines = zod_output.split("\n")

      # Find the Post schema definition
      in_post_schema = false
      lines.each do |line|
        if line.include?('export const Post =')
          in_post_schema = true
          next
        end

        next unless in_post_schema

        # Stop when we hit the next export
        if line.match?(/^export const \w+ =/) && !line.include?('Post =')
          break
        end

        # Regular attributes (id, title, body, etc.) should not have .optional()
        if line.match?(/^\s+(id|title|body|published|created_at|updated_at):/)
          expect(line).not_to include('.optional()'),
            "Regular attribute should not have .optional(): #{line}"
        end
      end
    end
  end

  describe 'TypeScript output reflects nullable for responses' do
    let(:typescript_output) { Apiwork::Spec::Typescript.generate('/api/v1') }

    it 'response interfaces have nullable types' do
      # Should have types like: email: string | null
      expect(typescript_output).to match(/\w+:\s*(?:\w+\s*\|\s*)?null/)
    end
  end
end
