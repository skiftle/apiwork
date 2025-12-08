# frozen_string_literal: true

module Apiwork
  module Generators
    class SchemaGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates/schema', __dir__)

      desc 'Creates an Apiwork schema'

      def create_schema
        template 'schema.rb.tt', schema_path
      end

      private

      def schema_path
        File.join('app/schemas', class_path, "#{file_name}_schema.rb")
      end

      def parent_class_name
        'ApplicationSchema'
      end
    end
  end
end
