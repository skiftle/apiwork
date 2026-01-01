# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps enum type definitions.
      #
      # @example
      #   data.enums.each do |enum|
      #     enum.name         # => :status
      #     enum.values       # => ["draft", "published", "archived"]
      #     enum.description  # => "Document status"
      #     enum.deprecated?  # => false
      #   end
      class Enum
        attr_reader :name

        def initialize(name, data)
          @name = name.to_sym
          @data = data || {}
        end

        # @return [Array<String>] allowed enum values
        def values
          @data[:values] || []
        end

        # @return [String, nil] enum description
        def description
          @data[:description]
        end

        # @return [String, nil] example value
        def example
          @data[:example]
        end

        # @return [Boolean] whether this enum is deprecated
        def deprecated?
          @data[:deprecated] == true
        end
      end
    end
  end
end
