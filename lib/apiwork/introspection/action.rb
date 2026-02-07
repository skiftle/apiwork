# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Wraps action definitions within a resource.
    #
    # @example
    #   resource.actions[:show].method     # => :get
    #   resource.actions[:show].path       # => "/posts/:id"
    #   resource.actions[:create].request  # => Action::Request
    #
    #   resource.actions.each_value do |action|
    #     action.method      # => :get, :post, :patch, :delete
    #     action.request     # => Action::Request
    #     action.response    # => Action::Response
    #     action.deprecated? # => false
    #   end
    class Action
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # Full path (e.g., "/posts/:id", "/posts").
      # @return [String]
      def path
        @dump[:path]
      end

      # @api public
      # HTTP method (:get, :post, :patch, :delete, :put).
      # @return [Symbol]
      def method
        @dump[:method]
      end

      # @api public
      # Request definition.
      # @return [Action::Request]
      # @see Action::Request
      def request
        @request ||= Request.new(@dump[:request])
      end

      # @api public
      # Response definition.
      # @return [Action::Response]
      # @see Action::Response
      def response
        @response ||= Response.new(@dump[:response])
      end

      # @api public
      # Error codes that may be raised.
      # @return [Array<Symbol>]
      def raises
        @dump[:raises]
      end

      # @api public
      # Short summary.
      # @return [String, nil]
      def summary
        @dump[:summary]
      end

      # @api public
      # Full description.
      # @return [String, nil]
      def description
        @dump[:description]
      end

      # @api public
      # OpenAPI tags.
      # @return [Array<String>]
      def tags
        @dump[:tags]
      end

      # @api public
      # OpenAPI operation ID.
      # @return [String, nil]
      def operation_id
        @dump[:operation_id]
      end

      # @api public
      # Whether deprecated.
      # @return [Boolean]
      def deprecated?
        @dump[:deprecated]
      end

      # @api public
      # Structured representation.
      # @return [Hash]
      def to_h
        {
          deprecated: deprecated?,
          description: description,
          method: method,
          operation_id: operation_id,
          path: path,
          raises: raises,
          request: request.to_h,
          response: response.to_h,
          summary: summary,
          tags: tags,
        }
      end
    end
  end
end
