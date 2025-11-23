# frozen_string_literal: true

module Apiwork
  module Adapter
    class RenderMetadata
      attr_reader :action_name,
                  :http_method,
                  :schema_data,
                  :contract_class

      def initialize(action_name:, http_method:, schema_data:, contract_class:)
        @action_name = action_name.to_sym
        @http_method = http_method.to_sym
        @schema_data = schema_data
        @contract_class = contract_class
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
        http_method == :get
      end

      def post?
        http_method == :post
      end

      def patch?
        http_method == :patch
      end

      def put?
        http_method == :put
      end

      def delete?
        http_method == :delete
      end
    end
  end
end
