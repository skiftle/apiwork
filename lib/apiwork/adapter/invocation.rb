# frozen_string_literal: true

module Apiwork
  module Adapter
    class Invocation
      attr_reader :action_name,
                  :method,
                  :context

      def initialize(action_name:, method:, context: {})
        @action_name = action_name.to_sym
        @method = method.to_sym
        @context = context
      end

      def index?
        action_name == :index
      end

      def show?
        action_name == :show
      end

      def create?
        action_name == :create
      end

      def update?
        action_name == :update
      end

      def destroy?
        action_name == :destroy
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
