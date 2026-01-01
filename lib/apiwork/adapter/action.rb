# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Describes a resource action.
    #
    # Passed in the `actions` hash to {Adapter::Base#register_contract}.
    # Available at runtime via {Adapter::RenderState#action}.
    #
    # @example
    #   actions.each do |name, action|
    #     if action.collection?
    #       # index-style
    #     end
    #   end
    class Action
      # @api public
      # @return [Symbol] action name (:index, :show, :create, :update, :destroy, or custom)
      attr_reader :name

      # @api public
      # @return [Symbol] HTTP method (:get, :post, :patch, :delete)
      attr_reader :method

      # @api public
      # @return [Symbol] action type (:member or :collection)
      attr_reader :type

      def initialize(name, method, type)
        @name = name.to_sym
        @method = method.to_sym
        @type = type&.to_sym
      end

      # @api public
      # @return [Boolean] true if action operates on a single resource
      def member?
        type == :member
      end

      # @api public
      # @return [Boolean] true if action operates on a collection
      def collection?
        type == :collection
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

      # @api public
      # @return [Boolean] true if this is a read operation (GET request)
      def read?
        get?
      end

      # @api public
      # @return [Boolean] true if this is a write operation (POST, PATCH, PUT, DELETE)
      def write?
        !read?
      end
    end
  end
end
