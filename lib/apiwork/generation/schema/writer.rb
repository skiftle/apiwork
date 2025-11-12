# frozen_string_literal: true

require 'fileutils'
require 'tempfile'

module Apiwork
  module Generation
    class Schema
      # Handles writing schema files to disk with atomic operations
      class Writer
        # Write schema content to file or directory structure
        #
        # @param content [String, Hash] Schema content to write
        # @param output [String] Output path (file or directory)
        # @param api_path [String, nil] API path (e.g., '/api/v1')
        # @param format [Symbol, nil] Schema format (e.g., :openapi)
        # @param extension [String] File extension (e.g., '.json', '.ts')
        # @return [String] Path to written file
        def self.write(content:, output:, extension:, api_path: nil, format: nil)
          if file_path?(output)
            # Single file mode - write directly
            write_file(content, output)
          else
            # Directory mode - create structure
            raise ArgumentError, 'api_path and format required when output is a directory' unless api_path && format

            file_path = build_file_path(output, api_path, format, extension)
            write_file(content, file_path)
          end
        end

        # Clean generated files
        #
        # @param output [String] Output path to clean
        def self.clean(output:)
          if File.exist?(output)
            if File.directory?(output)
              FileUtils.rm_rf(output)
              Rails.logger.debug "Cleaned directory: #{output}"
            else
              FileUtils.rm_f(output)
              Rails.logger.debug "Cleaned file: #{output}"
            end
          else
            Rails.logger.debug "Path does not exist: #{output}"
          end
        end

        # Check if path looks like a file (has extension)
        #
        # @param path [String] Path to check
        # @return [Boolean]
        def self.file_path?(path)
          File.extname(path) != ''
        end

        # Build file path for directory mode
        #
        # @param output [String] Base output directory
        # @param api_path [String] API path (e.g., '/api/v1')
        # @param format [Symbol] Schema format
        # @param extension [String] File extension
        # @return [String] Full file path
        def self.build_file_path(output, api_path, format, extension)
          # Convert api_path to directory structure: /api/v1 -> api/v1
          path_parts = api_path.split('/').reject(&:empty?)

          # Build path: output/api/v1/format.ext
          File.join(output, *path_parts, "#{format}#{extension}")
        end

        # Write content to file atomically
        #
        # @param content [String, Hash] Content to write
        # @param file_path [String] Destination file path
        # @return [String] Path to written file
        def self.write_file(content, file_path)
          # Ensure directory exists
          FileUtils.mkdir_p(File.dirname(file_path))

          # Convert Hash to JSON if needed
          content_string = if content.is_a?(Hash)
                             JSON.pretty_generate(content)
                           else
                             content.to_s
                           end

          # Atomic write: write to temp file, then move
          temp_file = Tempfile.new(['schema', File.extname(file_path)])
          begin
            temp_file.write(content_string)
            temp_file.close
            FileUtils.mv(temp_file.path, file_path)
          ensure
            temp_file.close
            temp_file.unlink if File.exist?(temp_file.path)
          end

          file_path
        end

        private_class_method :build_file_path, :write_file
      end
    end
  end
end
