# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Facade for introspected API data.
    #
    # Entry point for accessing all API data. Access resources via {#resources},
    # types via {#types}, enums via {#enums}.
    #
    # @example
    #   api = MyAPI.introspect(locale: :sv)
    #
    #   api.info.title              # => "My API"
    #   api.types.each { |t| ... }  # iterate custom types
    #   api.enums.each { |e| ... }  # iterate enums
    #
    #   api.each_resource do |resource, parent_path|
    #     resource.actions.each do |action|
    #       # ...
    #     end
    #   end
    class API
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # @return [String, nil] API mount path (e.g., "/api/v1")
      def path
        @dump[:path]
      end

      # @api public
      # @return [API::Info] API metadata
      # @see API::Info
      def info
        @info ||= Info.new(@dump[:info])
      end

      # @api public
      # @return [Array<API::Resource>] top-level resources
      # @see API::Resource
      def resources
        @resources ||= @dump[:resources].map do |name, data|
          Resource.new(name, data)
        end
      end

      # @api public
      # @return [Array<Type>] registered custom types
      # @see Type
      def types
        @types ||= @dump[:types].map do |name, data|
          Type.new(name, data)
        end
      end

      # @api public
      # @return [Array<Enum>] registered enums
      # @see Enum
      def enums
        @enums ||= @dump[:enums].map do |name, data|
          Enum.new(name, data)
        end
      end

      # @api public
      # @return [Array<Symbol>] API-level error codes that may be raised
      def raises
        @dump[:raises]
      end

      # @api public
      # @return [Array<ErrorCode>] error code definitions
      # @see ErrorCode
      def error_codes
        @error_codes ||= @dump[:error_codes].map do |code, data|
          ErrorCode.new(code, data)
        end
      end

      # @api public
      # Iterates over all resources recursively (including nested).
      #
      # @yieldparam resource [API::Resource] the resource
      # @yieldparam parent_path [String, nil] parent resource path
      # @see API::Resource
      def each_resource(&block)
        iterate_resources(resources, nil, &block)
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        {
          enums: enums.map(&:to_h),
          error_codes: error_codes.map(&:to_h),
          info: info.to_h,
          path: path,
          raises: raises,
          resources: resources.map(&:to_h),
          types: types.map(&:to_h),
        }
      end

      private

      def iterate_resources(resource_list, parent_path, &block)
        resource_list.each do |resource|
          yield(resource, parent_path)

          if resource.nested?
            current_path = parent_path ? "#{parent_path}/#{resource.path}" : resource.path
            iterate_resources(resource.resources, current_path, &block)
          end
        end
      end
    end
  end
end
