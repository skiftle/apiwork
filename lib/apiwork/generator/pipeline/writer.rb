# frozen_string_literal: true

require 'fileutils'
require 'tempfile'

module Apiwork
  module Generator
    class Pipeline
      # Writer handles filesystem I/O for generated artifacts
      #
      # Provides atomic writes using tempfiles and automatic directory creation.
      # Supports both single-file and directory-based output.
      #
      # Usage:
      #   Writer.write(content: '...', output: 'path/to/file.ts', extension: '.ts')
      #   Writer.clean(output: 'generated/')
      #
      class Writer
        # Write content to filesystem
        #
        # @param content [String, Hash] Content to write (Hash auto-converts to JSON)
        # @param output [String] Output path (file or directory)
        # @param extension [String] File extension (e.g., '.ts', '.json')
        # @param api_path [String, nil] API path (required for directory output)
        # @param format [Symbol, nil] Generator format (required for directory output)
        # @return [String] Path to written file
        def self.write(content:, output:, extension:, api_path: nil, format: nil)
          if file_path?(output)
            write_file(content, output)
          else
            raise ArgumentError, 'api_path and format required when output is a directory' unless api_path && format

            file_path = build_file_path(output, api_path, format, extension)
            write_file(content, file_path)
          end
        end

        # Clean generated files/directories
        #
        # @param output [String] Path to clean
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

        # Check if path is a file (has extension)
        #
        # @param path [String] Path to check
        # @return [Boolean] true if path has extension
        def self.file_path?(path)
          File.extname(path) != ''
        end

        # Build file path from components
        #
        # Constructs nested path: output/api/path/parts/format.extension
        #
        # @param output [String] Base output directory
        # @param api_path [String] API path (e.g., '/api/v1')
        # @param format [Symbol] Generator format
        # @param extension [String] File extension
        # @return [String] Complete file path
        def self.build_file_path(output, api_path, format, extension)
          path_parts = api_path.split('/').reject(&:empty?)
          File.join(output, *path_parts, "#{format}#{extension}")
        end
        private_class_method :build_file_path

        # Write content to file atomically using tempfile
        #
        # @param content [String, Hash] Content to write
        # @param file_path [String] Target file path
        # @return [String] Path to written file
        def self.write_file(content, file_path)
          FileUtils.mkdir_p(File.dirname(file_path))

          content_string = if content.is_a?(Hash)
                             JSON.pretty_generate(content)
                           else
                             content.to_s
                           end

          temp_file = Tempfile.new(['artifact', File.extname(file_path)])
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
        private_class_method :write_file
      end
    end
  end
end
