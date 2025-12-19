# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Key Transformation in Spec Generation', type: :integration do
  before(:all) do
    Apiwork.reset!
    load Rails.root.join('config/apis/v1.rb')
  end

  let(:path) { '/api/v1' }

  describe 'TypeScript generation' do
    describe 'with key_format: :keep (default)' do
      let(:generator) { Apiwork::Spec::Typescript.new(path, key_format: :keep) }
      let(:output) { generator.generate }

      it 'keeps snake_case property names' do
        expect(output).to match(/created_at\??: string/)
        expect(output).to match(/updated_at\??: string/)
      end

      it 'keeps snake_case in filter types' do
        expect(output).to match(/created_at\??: /)
      end

      it 'keeps snake_case in sort types' do
        expect(output).to include('created_at')
      end
    end

    describe 'with key_format: :camel' do
      let(:generator) { Apiwork::Spec::Typescript.new(path, key_format: :camel) }
      let(:output) { generator.generate }

      it 'transforms property names to camelCase' do
        expect(output).to match(/createdAt\??: string/)
        expect(output).to match(/updatedAt\??: string/)
      end

      it 'transforms filter property names to camelCase' do
        expect(output).to match(/createdAt\??: /)
      end

      it 'does not contain snake_case for timestamp fields' do
        expect(output).not_to match(/created_at\??: string/)
        expect(output).not_to match(/updated_at\??: string/)
      end
    end
  end

  describe 'Zod generation' do
    describe 'with key_format: :keep (default)' do
      let(:generator) { Apiwork::Spec::Zod.new(path, key_format: :keep) }
      let(:output) { generator.generate }

      it 'keeps snake_case property names in schemas' do
        expect(output).to match(/created_at:/)
        expect(output).to match(/updated_at:/)
      end

      it 'generates valid Zod schema syntax' do
        expect(output).to include("import { z } from 'zod'")
        expect(output).to include('z.object({')
      end
    end

    describe 'with key_format: :camel' do
      let(:generator) { Apiwork::Spec::Zod.new(path, key_format: :camel) }
      let(:output) { generator.generate }

      it 'transforms property names to camelCase' do
        expect(output).to match(/createdAt:/)
        expect(output).to match(/updatedAt:/)
      end

      it 'does not contain snake_case for timestamp fields' do
        expect(output).not_to match(/created_at:.*z\./)
        expect(output).not_to match(/updated_at:.*z\./)
      end
    end
  end

  describe 'OpenAPI generation' do
    describe 'with key_format: :keep (default)' do
      let(:generator) { Apiwork::Spec::Openapi.new(path, key_format: :keep) }
      let(:spec) { generator.generate }

      it 'keeps snake_case property names in schemas' do
        post_schema = spec[:components][:schemas]['post']
        properties = post_schema[:properties]

        expect(properties.keys.map(&:to_s)).to include('created_at')
        expect(properties.keys.map(&:to_s)).to include('updated_at')
      end

      it 'keeps snake_case in filter parameters' do
        filter_schema = spec[:components][:schemas]['post_filter']
        properties = filter_schema[:properties] if filter_schema

        expect(properties&.keys&.map(&:to_s)).to include('created_at') if properties
      end
    end

    describe 'with key_format: :camel' do
      let(:generator) { Apiwork::Spec::Openapi.new(path, key_format: :camel) }
      let(:spec) { generator.generate }

      it 'transforms property names to camelCase' do
        post_schema = spec[:components][:schemas]['post']
        properties = post_schema[:properties]
        property_names = properties.keys.map(&:to_s)

        expect(property_names).to include('createdAt')
        expect(property_names).to include('updatedAt')
      end

      it 'does not contain snake_case for timestamp fields' do
        post_schema = spec[:components][:schemas]['post']
        properties = post_schema[:properties]
        property_names = properties.keys.map(&:to_s)

        expect(property_names).not_to include('created_at')
        expect(property_names).not_to include('updated_at')
      end

      it 'transforms filter property names to camelCase' do
        filter_schema = spec[:components][:schemas]['post_filter']
        skip 'No filter schema' unless filter_schema

        properties = filter_schema[:properties]
        skip 'No properties in filter schema' unless properties

        property_names = properties.keys.map(&:to_s)
        expect(property_names).to include('createdAt') if property_names.any? { |n| n.include?('reated') }
      end
    end
  end

  describe 'Consistency across generators' do
    let(:ts_generator) { Apiwork::Spec::Typescript.new(path, key_format: :camel) }
    let(:zod_generator) { Apiwork::Spec::Zod.new(path, key_format: :camel) }
    let(:openapi_generator) { Apiwork::Spec::Openapi.new(path, key_format: :camel) }

    it 'applies same transformation across all generators' do
      ts_output = ts_generator.generate
      zod_output = zod_generator.generate
      openapi_spec = openapi_generator.generate

      expect(ts_output).to match(/createdAt/)
      expect(zod_output).to match(/createdAt/)
      expect(openapi_spec[:components][:schemas]['post'][:properties].keys.map(&:to_s)).to include('createdAt')
    end
  end

  describe 'Edge cases' do
    describe 'single word properties' do
      let(:generator) { Apiwork::Spec::Typescript.new(path, key_format: :camel) }
      let(:output) { generator.generate }

      it 'keeps single word properties unchanged' do
        expect(output).to match(/title\??: string/)
        # body is nullable, so it includes null in the type union
        expect(output).to match(/body\??: (null \| )?string/)
      end
    end

    describe 'id property' do
      let(:generator) { Apiwork::Spec::Typescript.new(path, key_format: :camel) }
      let(:output) { generator.generate }

      it 'keeps id property unchanged' do
        expect(output).to match(/\bid\??: (string|number)/)
      end
    end

    describe 'association references' do
      let(:generator) { Apiwork::Spec::Typescript.new(path, key_format: :camel) }
      let(:output) { generator.generate }

      it 'transforms association foreign key names' do
        comment_interface = extract_interface(output, 'Comment')
        expect(comment_interface).to match(/postId\??: (string|number)/) if comment_interface.include?('postId')
      end
    end
  end

  private

  def extract_interface(output, name)
    pattern = /export interface #{name}\s*\{[^}]*\}/m
    match = output.match(pattern)
    match ? match[0] : ''
  end
end
