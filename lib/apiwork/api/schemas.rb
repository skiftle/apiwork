# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Tracks schema usage metadata within an API.
    #
    # @example Check if a schema is used as a nested writable target
    #   api.schemas.nested_writable?(CommentSchema)
    class Schemas
      def initialize
        @roles = Hash.new { |h, k| h[k] = Set.new }
      end

      # @api public
      # Marks a schema with a usage role.
      #
      # @param schema_class [Class] a Schema::Base subclass
      # @param role [Symbol] the role (e.g., :nested_writable)
      # @return [void]
      def mark(schema_class, role)
        @roles[schema_class].add(role)
      end

      # @api public
      # Checks if a schema is used as a nested writable target.
      #
      # A schema is marked as nested writable when another schema
      # has a writable association pointing to it.
      #
      # @param schema_class [Class] a Schema::Base subclass
      # @return [Boolean]
      def nested_writable?(schema_class)
        @roles[schema_class].include?(:nested_writable)
      end
    end
  end
end
