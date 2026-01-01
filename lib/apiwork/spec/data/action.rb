# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
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
        attr_reader :name

        def initialize(name, data)
          @name = name.to_sym
          @data = data || {}
        end

        # @return [String] action path segment (e.g., "/:id", "/")
        def path
          @data[:path]
        end

        # @return [Symbol] HTTP method (:get, :post, :patch, :delete, :put)
        def http_method
          @data[:method]
        end

        # @return [Request, nil] request definition
        def request
          @request ||= @data[:request] ? Request.new(@data[:request]) : nil
        end

        # @return [Response, nil] response definition
        def response
          @response ||= @data[:response] ? Response.new(@data[:response]) : nil
        end

        # @return [Array<Symbol>] error codes this action may raise
        def raises
          @data[:raises] || []
        end

        # @return [String, nil] short summary
        def summary
          @data[:summary]
        end

        # @return [String, nil] full description
        def description
          @data[:description]
        end

        # @return [Array<String>] OpenAPI tags
        def tags
          @data[:tags] || []
        end

        # @return [String, nil] OpenAPI operation ID
        def operation_id
          @data[:operation_id]
        end

        # @return [Boolean] whether this action is deprecated
        def deprecated?
          @data[:deprecated] == true
        end

        # @return [Boolean] whether a request is defined
        def request?
          request.present?
        end

        # @return [Boolean] whether a response is defined
        def response?
          response.present?
        end

        # @return [Hash] the raw underlying data hash
        def to_h
          @data
        end
      end
    end
  end
end
