# frozen_string_literal: true

module Apiwork
  module Errors
    # JSON Pointer (RFC 6901) implementation
    module JSONPointer
      # Build a JSON Pointer string from a path array
      #
      # @param path [Array<Symbol, String, Integer>] Path components
      # @return [String] JSON Pointer string (e.g., "/data/name")
      def self.build(*path)
        return '' if path.empty?

        "/#{path.map { |component| escape_component(component.to_s) }.join('/')}"
      end

      def self.escape_component(component)
        component.gsub('~', '~0').gsub('/', '~1')
      end
    end
  end
end
