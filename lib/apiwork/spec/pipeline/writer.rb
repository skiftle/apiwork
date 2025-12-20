# frozen_string_literal: true

require 'fileutils'
require 'tempfile'

module Apiwork
  module Spec
    class Pipeline
      class Writer
        class << self
          def write(content:, output:, extension:, api_path: nil, spec_name: nil)
            if file_path?(output)
              write_file(content, output)
            else
              raise ArgumentError, 'api_path and spec_name required when output is a directory' if api_path.blank? || spec_name.blank?

              file_path = build_file_path(output, api_path, spec_name, extension)
              write_file(content, file_path)
            end
          end

          def clean(output:)
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

          def file_path?(path)
            File.extname(path) != ''
          end

          private

          def build_file_path(output, api_path, spec_name, extension)
            path_parts = api_path.split('/').reject(&:empty?)
            File.join(output, *path_parts, "#{spec_name}#{extension}")
          end

          def write_file(content, file_path)
            FileUtils.mkdir_p(File.dirname(file_path))

            formatted_content = if content.is_a?(Hash)
                                  JSON.pretty_generate(content)
                                else
                                  content.to_s
                                end

            temp_file = Tempfile.new(['artifact', File.extname(file_path)])
            begin
              temp_file.write(formatted_content)
              temp_file.close
              FileUtils.mv(temp_file.path, file_path)
            ensure
              temp_file.close
              temp_file.unlink if File.exist?(temp_file.path)
            end

            file_path
          end
        end
      end
    end
  end
end
