# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Wraps action definitions within a resource.
    #
    # @example
    #   resource.actions.each do |action|
    #     action.name        # => :index, :show, :create, etc.
    #     action.method      # => :get, :post, :patch, :delete
    #     action.path        # => "/" or "/:id"
    #     action.request     # => Action::Request or nil
    #     action.response    # => Action::Response or nil
    #     action.deprecated? # => false
    #   end
    class Action
      # @api public
      # @return [Symbol] action name
      attr_reader :name

      def initialize(name, dump)
        @name = name.to_sym
        @dump = dump
      end

      # @api public
      # @return [String] action path segment (e.g., "/:id", "/")
      def path
        @dump[:path]
      end

      # @api public
      # @return [Symbol] HTTP method (:get, :post, :patch, :delete, :put)
      def method
        @dump[:method]
      end

      # @api public
      # @return [Action::Request, nil] request definition
      # @see Action::Request
      def request
        @request ||= @dump[:request] ? Request.new(@dump[:request]) : nil
      end

      # @api public
      # @return [Action::Response, nil] response definition
      # @see Action::Response
      def response
        @response ||= @dump[:response] ? Response.new(@dump[:response]) : nil
      end

      # @api public
      # @return [Array<Symbol>] error codes this action may raise
      def raises
        @dump[:raises] || []
      end

      # @api public
      # @return [String, nil] short summary
      def summary
        @dump[:summary]
      end

      # @api public
      # @return [String, nil] full description
      def description
        @dump[:description]
      end

      # @api public
      # @return [Array<String>] OpenAPI tags
      def tags
        @dump[:tags] || []
      end

      # @api public
      # @return [String, nil] OpenAPI operation ID
      def operation_id
        @dump[:operation_id]
      end

      # @api public
      # @return [Boolean] whether this action is deprecated
      def deprecated?
        @dump[:deprecated] == true
      end

      # @api public
      # @return [Boolean] whether a request is defined
      def request?
        request.present?
      end

      # @api public
      # @return [Boolean] whether a response is defined
      def response?
        response.present?
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        {
          deprecated: deprecated?,
          description: description,
          method: method,
          name: name,
          operation_id: operation_id,
          path: path,
          raises: raises,
          request: request&.to_h,
          response: response&.to_h,
          summary: summary,
          tags: tags,
        }
      end
    end
  end
end
