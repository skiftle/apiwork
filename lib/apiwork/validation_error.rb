# frozen_string_literal: true

module Apiwork
  class ValidationError < Error
    class Issue
      attr_reader :code, :path, :meta, :message

      def initialize(code:, message:, path: [], meta: {})
        @code = code
        @path = Array(path).map { |element| element.is_a?(Integer) ? element : element.to_sym }
        @meta = meta
        @message = message
      end

      def self.from_model_validation(rails_error, path: [])
        meta = { attribute: rails_error.attribute }

        if rails_error.options
          %i[in minimum maximum count is too_short too_long].each do |key|
            value = rails_error.options[key]
            meta[key] = value if value
          end
        end

        new(
          code: rails_error.type,
          message: rails_error.message,
          path: path,
          meta: meta
        )
      end

      def pointer
        @pointer ||= Errors::JSONPointer.build(*path)
      end

      def dot_path
        @dot_path ||= path.map(&:to_s).join('.')
      end

      def to_h
        filtered_meta = meta.is_a?(Hash) ? meta.slice(:attribute, :in, :minimum, :maximum, :count, :is, :too_short, :too_long) : meta

        result = {
          code: code,
          path: path.map(&:to_s),
          pointer: pointer,
          detail: message
        }

        result[:options] = filtered_meta if filtered_meta && (filtered_meta.respond_to?(:empty?) ? !filtered_meta.empty? : true)
        result
      end
    end

    attr_reader :issues

    def initialize(issues)
      @issues = Array(issues)
      super(@issues.map(&:message).join('; '))
    end

    def to_array
      @issues.map(&:to_h)
    end

    def empty?
      @issues.empty?
    end

    def any?
      @issues.any?
    end
  end
end
