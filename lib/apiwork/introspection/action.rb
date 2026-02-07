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
      # @return [String]
      def path
        @dump[:path]
      end

      # @api public
      # @return [Symbol] HTTP method (:get, :post, :patch, :delete, :put)
      def method
        @dump[:method]
      end

      # @api public
      # @return [Action::Request]
      # @see Action::Request
      def request
        @request ||= Request.new(@dump[:request])
      end

      # @api public
      # @return [Action::Response]
      # @see Action::Response
      def response
        @response ||= Response.new(@dump[:response])
      end

      # @api public
      # @return [Array<Symbol>]
      def raises
        @dump[:raises]
      end

      # @api public
      # @return [String, nil]
      def summary
        @dump[:summary]
      end

      # @api public
      # @return [String, nil]
      def description
        @dump[:description]
      end

      # @api public
      # @return [Array<String>] OpenAPI tags
      def tags
        @dump[:tags]
      end

      # @api public
      # @return [String, nil] OpenAPI operation ID
      def operation_id
        @dump[:operation_id]
      end

      # @api public
      # @return [Boolean]
      def deprecated?
        @dump[:deprecated]
      end

      # @api public
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
