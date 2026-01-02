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
    #   api.info.title                      # => "My API"
    #   api.types[:address].description     # => "Address type"
    #   api.enums[:status].values           # => ["draft", "published"]
    #
    #   api.each_resource do |resource, parent_path|
    #     resource.actions.each_value do |action|
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
      # @return [Hash{Symbol => API::Resource}] top-level resources
      # @see API::Resource
      def resources
        @resources ||= @dump[:resources].transform_values { |data| Resource.new(data) }
      end

      # @api public
      # @return [Hash{Symbol => Type}] registered custom types
      # @see Type
      def types
        @types ||= @dump[:types].transform_values { |data| Type.new(data) }
      end

      # @api public
      # @return [Hash{Symbol => Enum}] registered enums
      # @see Enum
      def enums
        @enums ||= @dump[:enums].transform_values { |data| Enum.new(data) }
      end

      # @api public
      # @return [Array<Symbol>] API-level error codes that may be raised
      def raises
        @dump[:raises]
      end

      # @api public
      # @return [Hash{Symbol => ErrorCode}] error code definitions
      # @see ErrorCode
      def error_codes
        @error_codes ||= @dump[:error_codes].transform_values { |data| ErrorCode.new(data) }
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
          enums: enums.transform_values(&:to_h),
          error_codes: error_codes.transform_values(&:to_h),
          info: info.to_h,
          path: path,
          raises: raises,
          resources: resources.transform_values(&:to_h),
          types: types.transform_values(&:to_h),
        }
      end

      private

      def iterate_resources(resource_list, parent_path, &block)
        resource_list.each_value do |resource|
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
