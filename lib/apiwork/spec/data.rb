# frozen_string_literal: true

module Apiwork
  module Spec
    # @api public
    # Wraps introspection data for spec generators.
    #
    # Entry point for accessing all API data in a spec generator.
    # Access resources via {#resources}, types via {#types}, enums via {#enums}.
    #
    # @see Data::Resource
    # @see Data::Type
    # @see Data::Enum
    # @see Data::Info
    #
    # @example
    #   data = Spec::Data.new(introspection_data)
    #
    #   data.info.title              # => "My API"
    #   data.types.each { |t| ... }  # iterate custom types
    #   data.enums.each { |e| ... }  # iterate enums
    #
    #   data.each_resource do |resource, parent_path|
    #     resource.actions.each do |action|
    #       # ...
    #     end
    #   end
    class Data
      def initialize(introspection)
        @introspection = introspection || {}
      end

      # @api public
      # @return [String, nil] API mount path (e.g., "/api/v1")
      def path
        @introspection[:path]
      end

      # @api public
      # @return [Data::Info] API metadata
      # @see Data::Info
      def info
        @info ||= Info.new(@introspection[:info])
      end

      # @api public
      # @return [Array<Data::Resource>] top-level resources
      # @see Data::Resource
      def resources
        @resources ||= (@introspection[:resources] || {}).map do |name, data|
          Resource.new(name, data)
        end
      end

      # @api public
      # @return [Array<Data::Type>] registered custom types
      # @see Data::Type
      def types
        @types ||= (@introspection[:types] || {}).map do |name, data|
          Type.new(name, data)
        end
      end

      # @api public
      # @return [Array<Data::Enum>] registered enums
      # @see Data::Enum
      def enums
        @enums ||= (@introspection[:enums] || {}).map do |name, data|
          Enum.new(name, data)
        end
      end

      # @api public
      # @return [Array<Symbol>] API-level error codes that may be raised
      def raises
        @introspection[:raises] || []
      end

      # @api public
      # @return [Array<Data::ErrorCode>] error code definitions
      # @see Data::ErrorCode
      def error_codes
        @error_codes ||= (@introspection[:error_codes] || {}).map do |code, data|
          ErrorCode.new(code, data)
        end
      end

      # @api public
      # Iterates over all resources recursively (including nested).
      #
      # @yieldparam resource [Data::Resource] the resource
      # @yieldparam parent_path [String, nil] parent resource path
      # @see Data::Resource
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
