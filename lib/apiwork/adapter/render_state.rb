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
    #   def render_record(record, representation_class, state)
    #     if state.action.show?
    #       { data: serialize(record) }
    #     else
    #       { data: serialize(record), links: { self: url_for(record) } }
    #     end
    #   end
    #
    # @example Check HTTP method
    #   def render_collection(collection, representation_class, state)
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
      # @return [Adapter::Request, nil] the parsed request
      attr_reader :request

      # @api public
      # @return [Class, nil] the representation class for this request
      attr_reader :representation_class

      def initialize(action, context: {}, meta: {}, representation_class: nil, request: nil)
        @action = action
        @context = context
        @meta = meta
        @request = request
        @representation_class = representation_class
      end
    end
  end
end
