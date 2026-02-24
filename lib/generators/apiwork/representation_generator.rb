# frozen_string_literal: true

module Apiwork
  module Generators
    class RepresentationGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates/representation', __dir__)

      desc 'Creates an Apiwork representation'

      def create_representation
        template 'representation.rb.tt', representation_path
      end

      private

      def representation_path
        File.join('app/representations', class_path, "#{file_name}_representation.rb")
      end

      def parent_class_name
        'ApplicationRepresentation'
      end
    end
  end
end
