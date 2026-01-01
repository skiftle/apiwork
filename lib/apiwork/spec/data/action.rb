# frozen_string_literal: true

module Apiwork
  module Spec
    class Data
      # @api public
      # Wraps action definitions within a resource.
      #
      # @example
      #   resource.actions.each do |action|
      #     action.name        # => :index, :show, :create, etc.
      #     action.method      # => :get, :post, :patch, :delete
      #     action.path        # => "/" or "/:id"
      #     action.request     # => Request or nil
      #     action.response    # => Response or nil
      #     action.deprecated? # => false
      #   end
      class Action
        # @api public
        # @return [Symbol] action name
        attr_reader :name

        def initialize(name, data)
          @name = name.to_sym
          @data = data || {}
        end

        # @api public
        # @return [String] action path segment (e.g., "/:id", "/")
        def path
          @data[:path]
        end

        # @api public
        # @return [Symbol] HTTP method (:get, :post, :patch, :delete, :put)
        def method
          @data[:method]
        end

        # @api public
        # @return [Request, nil] request definition
        # @see Request
        def request
          @request ||= @data[:request] ? Request.new(@data[:request]) : nil
        end

        # @api public
        # @return [Response, nil] response definition
        # @see Response
        def response
          @response ||= @data[:response] ? Response.new(@data[:response]) : nil
        end

        # @api public
        # @return [Array<Symbol>] error codes this action may raise
        def raises
          @data[:raises] || []
        end

        # @api public
        # @return [String, nil] short summary
        def summary
          @data[:summary]
        end

        # @api public
        # @return [String, nil] full description
        def description
          @data[:description]
        end

        # @api public
        # @return [Array<String>] OpenAPI tags
        def tags
          @data[:tags] || []
        end

        # @api public
        # @return [String, nil] OpenAPI operation ID
        def operation_id
          @data[:operation_id]
        end

        # @api public
        # @return [Boolean] whether this action is deprecated
        def deprecated?
          @data[:deprecated] == true
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
end
