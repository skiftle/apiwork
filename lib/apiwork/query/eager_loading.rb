# frozen_string_literal: true

module Apiwork
  class Query
    module EagerLoading
      def apply_includes(scope, params = {})
        return scope if schema.association_definitions.empty?

        includes_hash = IncludesResolver.new(schema: schema).build(params: params, for_collection: true)
        return scope if includes_hash.empty?

        scope.includes(includes_hash)
      end
    end
  end
end
