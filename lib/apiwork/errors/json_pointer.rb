# frozen_string_literal: true

module Apiwork
  module Errors
    # JSON Pointer (RFC 6901) implementation for error path generation
    # Converts path arrays to JSON Pointer strings
    #
    # Examples:
    #   Errors::JSONPointer.build(:data, :name)              # => "/data/name"
    #   Errors::JSONPointer.build(:data, :address, :street)  # => "/data/address/street"
    #   Errors::JSONPointer.build(:data, :sites, 0, :name)   # => "/data/sites/0/name"
    #   Errors::JSONPointer.build(:filter, :name)            # => "/filter/name"
    module JSONPointer
      # Build a JSON Pointer string from a path array
      #
      # @param path [Array<Symbol, String, Integer>] Path components
      # @return [String] JSON Pointer string (e.g., "/data/name")
      def self.build(*path)
        return '' if path.empty?

        "/#{path.map { |component| escape_component(component.to_s) }.join('/')}"
      end

      # Escape special characters in JSON Pointer component
      # Per RFC 6901: ~ must be encoded as ~0, / must be encoded as ~1
      #
      # @param component [String] Path component to escape
      # @return [String] Escaped component
      def self.escape_component(component)
        component.gsub('~', '~0').gsub('/', '~1')
      end
    end
  end
end
