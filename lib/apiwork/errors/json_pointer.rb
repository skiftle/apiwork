# frozen_string_literal: true

module Apiwork
  module Errors
    # JSON Pointer (RFC 6901) implementation
    module JSONPointer
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
