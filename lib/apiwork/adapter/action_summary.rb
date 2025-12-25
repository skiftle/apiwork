# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Request context passed to adapter render methods.
    #
    # Contains the action name, HTTP method, and optional context.
    # Use predicates to branch logic based on action or method.
    #
    # @example Check action type
    #   def render_record(record, schema_class, action_summary)
    #     if action_summary.show?
    #       { data: serialize(record) }
    #     else
    #       { data: serialize(record), links: { self: url_for(record) } }
    #     end
    #   end
    #
    # @example Check HTTP method
    #   def render_collection(collection, schema_class, action_summary)
    #     response = { data: collection.map { |r| serialize(r) } }
    #     response[:cache] = true if action_summary.get?
    #     response
    #   end
    class ActionSummary
      # @api public
      # @return [Symbol] the action name (:index, :show, :create, :update, :destroy, or custom)
      attr_reader :name

      # @api public
      # @return [Symbol] the HTTP method (:get, :post, :patch, :put, :delete)
      attr_reader :method

      # @api public
      # @return [Hash] arbitrary context passed from the controller
      attr_reader :context

      # @api public
      # @return [Hash] parsed query parameters
      attr_reader :query

      # @api public
      # @return [Hash] metadata for the response
      attr_reader :meta

      def initialize(name, method, context: {}, query: {}, meta: {})
        @name = name.to_sym
        @method = method.to_sym
        @context = context
        @query = query
        @meta = meta
      end

      # @api public
      # @return [Boolean] true if this is an index action
      def index?
        name == :index
      end

      # @api public
      # @return [Boolean] true if this is a show action
      def show?
        name == :show
      end

      # @api public
      # @return [Boolean] true if this is a create action
      def create?
        name == :create
      end

      # @api public
      # @return [Boolean] true if this is an update action
      def update?
        name == :update
      end

      # @api public
      # @return [Boolean] true if this is a destroy action
      def destroy?
        name == :destroy
      end

      # @api public
      # @return [Boolean] true if HTTP method is GET
      def get?
        method == :get
      end

      # @api public
      # @return [Boolean] true if HTTP method is POST
      def post?
        method == :post
      end

      # @api public
      # @return [Boolean] true if HTTP method is PATCH
      def patch?
        method == :patch
      end

      # @api public
      # @return [Boolean] true if HTTP method is PUT
      def put?
        method == :put
      end

      # @api public
      # @return [Boolean] true if HTTP method is DELETE
      def delete?
        method == :delete
      end
    end
  end
end
