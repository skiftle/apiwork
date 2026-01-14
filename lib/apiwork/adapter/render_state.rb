# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Runtime state passed to adapter render methods.
    #
    # Contains the action and optional context.
    # Access action predicates via `state.action.index?`.
    #
    # @example Check action type
    #   def render_record(record, schema_class, state)
    #     if state.action.show?
    #       { data: serialize(record) }
    #     else
    #       { data: serialize(record), links: { self: url_for(record) } }
    #     end
    #   end
    #
    # @example Check HTTP method
    #   def render_collection(collection, schema_class, state)
    #     response = { data: collection.map { |record| serialize(record) } }
    #     response[:cache] = true if state.action.get?
    #     response
    #   end
    class RenderState
      # @api public
      # @return [Adapter::Action] the current action
      attr_reader :action

      # @api public
      # @return [Hash] arbitrary context passed from the controller
      attr_reader :context

      # @api public
      # @return [Hash] metadata for the response
      attr_reader :meta

      # @api public
      # @return [Hash] parsed query parameters
      attr_reader :query

      def initialize(action, context: {}, meta: {}, query: {})
        @action = action
        @context = context
        @meta = meta
        @query = query
      end
    end
  end
end
