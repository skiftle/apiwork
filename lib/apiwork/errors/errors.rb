# frozen_string_literal: true

require_relative 'json_pointer'

module Apiwork
  # Base error classes
  class Error < StandardError; end
  class DependencyError < Error; end
  class ConfigurationError < Error; end
  class TransformationError < Error; end
  class APIError < StandardError; end

  # Structured error with metadata for API responses
  class StructuredError < Error
    attr_reader :code, :path, :detail, :metadata

    def initialize(code:, detail:, path: [], **metadata)
      @code = code
      @detail = detail
      @path = Array(path).map { |element| element.is_a?(Integer) ? element : element.to_sym }
      @metadata = metadata
      super(detail)
    end

    def pointer
      @pointer ||= Errors::JSONPointer.build(*path)
    end

    def dot_path
      @dot_path ||= path.map(&:to_s).join('.')
    end

    def to_h
      useful_keys = %i[attribute in minimum maximum count is too_short too_long]
      filtered_metadata = metadata.slice(*useful_keys)

      result = {
        code: code,
        path: path.map(&:to_s),
        pointer: pointer,
        detail: detail
      }

      result[:options] = filtered_metadata if filtered_metadata.any?
      result.compact
    end

    def self.for_rails_validation(rails_error, path: [])
      metadata = { attribute: rails_error.attribute }

      if rails_error.options
        metadata[:in] = rails_error.options[:in] if rails_error.options[:in]
        metadata[:minimum] = rails_error.options[:minimum] if rails_error.options[:minimum]
        metadata[:maximum] = rails_error.options[:maximum] if rails_error.options[:maximum]
        metadata[:count] = rails_error.options[:count] if rails_error.options[:count]
        metadata[:is] = rails_error.options[:is] if rails_error.options[:is]
        metadata[:too_short] = rails_error.options[:too_short] if rails_error.options[:too_short]
        metadata[:too_long] = rails_error.options[:too_long] if rails_error.options[:too_long]
      end

      new(
        code: rails_error.type,
        detail: rails_error.message,
        path: path,
        **metadata
      )
    end
  end

  # Specific error types
  class FilterError < StructuredError; end
  class SortError < StructuredError; end
  class SerializationError < StructuredError; end
  class PaginationError < StructuredError; end

  # Collection of structured errors
  class StructuredErrorCollection < Error
    attr_reader :errors

    def initialize(errors = [])
      errors = errors.errors if errors.is_a?(StructuredErrorCollection)

      @errors = Array(errors).map do |error|
        if error.is_a?(StructuredError)
          error
        else
          StructuredError.new(
            code: :validation_error,
            detail: error.to_s,
            path: []
          )
        end
      end
      super(@errors.map(&:detail).join('; '))
    end

    def to_array
      @errors.map(&:to_h)
    end

    def to_h
      { errors: to_array }
    end

    def empty?
      @errors.empty?
    end

    def any?
      !empty?
    end

    def <<(error)
      @errors << (if error.is_a?(StructuredError)
                    error
                  else
                    StructuredError.new(code: :validation_error,
                                        detail: error.to_s, path: [])
                  end)
    end

    def each(&block)
      @errors.each(&block)
    end

    def size
      @errors.size
    end

    def concat(other_errors)
      @errors.concat(Array(other_errors))
    end
  end

  # Error context for tracking validation error paths
  class ErrorContext
    attr_reader :path, :root_key, :context_type

    def initialize(root_key: nil, context_type: :body, path: [])
      @root_key = root_key
      @context_type = context_type
      @path = Array(path)
    end

    def path_for(field)
      if @root_key
        [@root_key, *@path, field.to_sym]
      else
        [*@path, field.to_sym]
      end
    end

    def path_for_array_item(field, index)
      if @root_key
        [@root_key, *@path, field.to_sym, index]
      else
        [*@path, field.to_sym, index]
      end
    end

    def add_field(field)
      self.class.new(
        root_key: @root_key,
        context_type: @context_type,
        path: [@path, field.to_sym].flatten
      )
    end

    def with_path(new_path)
      self.class.new(
        root_key: nil,
        context_type: @context_type,
        path: Array(new_path)
      )
    end

    def for_array_item(field, index)
      new_path = if @root_key
                   [@root_key, *@path, field.to_sym, index]
                 else
                   [*@path, field.to_sym, index]
                 end

      self.class.new(
        root_key: nil,
        context_type: @context_type,
        path: new_path
      )
    end
  end
end
