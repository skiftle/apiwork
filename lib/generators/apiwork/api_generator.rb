# frozen_string_literal: true

module Apiwork
  module Generators
    class ApiGenerator < Rails::Generators::Base
      source_root File.expand_path('templates/api', __dir__)

      argument :mount_path, type: :string, desc: 'The API mount path (e.g., /api/v1 or /)'

      desc 'Creates an Apiwork API definition'

      def create_api_definition
        template 'api.rb.tt', "config/apis/#{file_name}.rb"
      end

      private

      def file_name
        path_segments.empty? ? 'root' : path_segments.join('_')
      end

      def api_mount_path
        path_segments.empty? ? '/' : "/#{path_segments.join('/')}"
      end

      def path_segments
        @path_segments ||= normalize(mount_path)
      end

      def normalize(input)
        normalized = input.to_s.gsub('::', '/').underscore.delete_prefix('/').strip
        return [] if normalized.empty?

        normalized.split('/')
      end
    end
  end
end
