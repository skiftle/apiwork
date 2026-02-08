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
      # The path for this action.
      #
      # @return [String]
      def path
        @dump[:path]
      end

      # @api public
      # The HTTP method for this action.
      #
      # @return [Symbol]
      def method
        @dump[:method]
      end

      # @api public
      # The request for this action.
      #
      # @return [Action::Request]
      def request
        @request ||= Request.new(@dump[:request])
      end

      # @api public
      # The response for this action.
      #
      # @return [Action::Response]
      def response
        @response ||= Response.new(@dump[:response])
      end

      # @api public
      # The error codes for this action.
      #
      # @return [Array<Symbol>]
      def raises
        @dump[:raises]
      end

      # @api public
      # The summary for this action.
      #
      # @return [String, nil]
      def summary
        @dump[:summary]
      end

      # @api public
      # The description for this action.
      #
      # @return [String, nil]
      def description
        @dump[:description]
      end

      # @api public
      # The tags for this action.
      #
      # @return [Array<String>]
      def tags
        @dump[:tags]
      end

      # @api public
      # The operation ID for this action.
      #
      # @return [String, nil]
      def operation_id
        @dump[:operation_id]
      end

      # @api public
      # Whether this action is deprecated.
      #
      # @return [Boolean]
      def deprecated?
        @dump[:deprecated]
      end

      # @api public
      # Converts this action to a hash.
      #
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
