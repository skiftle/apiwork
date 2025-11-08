# frozen_string_literal: true

module Apiwork
  class Query
    module EagerLoading
      # Apply eager loading to scope using IncludesBuilder
      def apply_includes(scope, params = {})
        return scope if schema.association_definitions.empty?

        includes_hash = IncludesBuilder.new(schema: schema).build(params: params, for_collection: true)
        return scope if includes_hash.empty?

        scope.includes(includes_hash)
      end
    end
  end
end
