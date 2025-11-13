# frozen_string_literal: true

require 'fileutils'
require 'tempfile'

module Apiwork
  module Generation
    class Spec
      class Writer
        def self.write(content:, output:, extension:, api_path: nil, format: nil)
          if file_path?(output)
            write_file(content, output)
          else
            raise ArgumentError, 'api_path and format required when output is a directory' unless api_path && format

            file_path = build_file_path(output, api_path, format, extension)
            write_file(content, file_path)
          end
        end

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

        def self.file_path?(path)
          File.extname(path) != ''
        end

        def self.build_file_path(output, api_path, format, extension)
          path_parts = api_path.split('/').reject(&:empty?)
          File.join(output, *path_parts, "#{format}#{extension}")
        end

        def self.write_file(content, file_path)
          FileUtils.mkdir_p(File.dirname(file_path))

          content_string = if content.is_a?(Hash)
                             JSON.pretty_generate(content)
                           else
                             content.to_s
                           end

          temp_file = Tempfile.new(['spec', File.extname(file_path)])
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
