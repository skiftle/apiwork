# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api private
    class ActionData
      attr_reader :name,
                  :method,
                  :context,
                  :query,
                  :meta

      def initialize(name, method, context: {}, query: {}, meta: {})
        @name = name.to_sym
        @method = method.to_sym
        @context = context
        @query = query
        @meta = meta
      end

      def index?
        name == :index
      end

      def show?
        name == :show
      end

      def create?
        name == :create
      end

      def update?
        name == :update
      end

      def destroy?
        name == :destroy
      end

      def get?
        method == :get
      end

      def post?
        method == :post
      end

      def patch?
        method == :patch
      end

      def put?
        method == :put
      end

      def delete?
        method == :delete
      end
    end
  end
end
