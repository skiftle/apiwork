# frozen_string_literal: true

module Apiwork
  # Builds and validates output responses for a contract action
  #
  # Handles:
  # - Response building via ResponseRenderer
  # - Output validation against contract's output_definition
  #
  # Usage:
  #   output = ActionOutput.new(
  #     contract: MyContract.new,
  #     action: :create,
  #     context: { current_user: user }
  #   )
  #   result = output.perform(resource, meta: {})
  #
  #   render json: result.response if result.valid?
  #
  class ActionOutput
    attr_reader :contract, :action, :action_definition, :schema_class, :context

    def initialize(contract:, action:, **options)
      @contract = contract
      @action = action.to_sym
      @context = options[:context] || {}
      @action_definition = contract.class.action_definition(@action)
      @schema_class = @action_definition&.schema_class
      @request_method = options[:request_method]
    end

    # Build and validate output response
    #
    # @param resource [Object] Resource or collection to render
    # @param meta [Hash] Additional meta information
    # @param query_params [Hash] Query parameters (filter, sort, page, include) for collections
    # @return [Result] Result object with response and errors
    def perform(resource, meta: {}, query_params: {})
      # Transform meta keys if schema exists
      transformed_meta = transform_meta_keys(meta)

      # Build response using internal ResponseRenderer
      response = build_response(resource, transformed_meta, query_params)

      Result.new(response: response, errors: [])
    end

    private

    # Transform meta keys to match schema's key transform
    def transform_meta_keys(meta)
      return meta unless meta.present? && @schema_class

      meta_key_transform = @schema_class.serialize_key_transform
      Apiwork::Transform::Case.hash(meta, meta_key_transform)
    end

    # Build response using ResponseRenderer
    def build_response(resource, meta, query_params)
      # Create a minimal controller-like object for ResponseRenderer
      renderer_context = RendererContext.new(@action, @request_method, @context, query_params)

      Controller::ResponseRenderer.new(
        controller: renderer_context,
        action_definition: @action_definition,
        schema_class: @schema_class,
        meta: meta
      ).perform(resource)
    end

    # Minimal controller-like object for ResponseRenderer
    class RendererContext
      attr_reader :request

      def initialize(action_name, request_method, schema_context, query_params = {})
        @action_name = action_name
        @request_method = request_method
        @schema_context = schema_context
        @query_params = query_params
        @request = RequestStub.new(request_method)
      end

      def action_name
        @action_name.to_s
      end

      def build_schema_context
        @schema_context
      end

      # Stub action_input that returns query params
      def action_input
        OpenStruct.new(params: @query_params)
      end

      # Stub params that returns query params
      def params
        @query_params
      end

      # Stub request object
      class RequestStub
        def initialize(method)
          @method = method&.to_s&.downcase
        end

        def delete?
          @method == 'delete'
        end

        def post?
          @method == 'post'
        end

        def get?
          @method == 'get'
        end

        def patch?
          @method == 'patch'
        end

        def put?
          @method == 'put'
        end

        def method
          @method
        end
      end
    end

    # Result object wrapping rendered response
    class Result
      attr_reader :response, :errors

      def initialize(response:, errors:)
        @response = response
        @errors = errors
      end

      # Check if rendering succeeded
      #
      # @return [Boolean] true if no errors
      def valid?
        errors.empty?
      end

      # Check if rendering failed
      #
      # @return [Boolean] true if errors present
      def invalid?
        errors.any?
      end
    end
  end
end
