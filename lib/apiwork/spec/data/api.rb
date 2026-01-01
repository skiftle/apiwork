# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps the root introspection data.
      #
      # This is the entry point for accessing all API data in a spec generator.
      # Provides object-oriented access to resources, types, enums, and metadata.
      #
      # @example
      #   api = Spec::Data::API.new(introspection_data)
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
        def initialize(data)
          @data = data || {}
        end

        # @return [String, nil] API mount path (e.g., "/api/v1")
        def path
          @data[:path]
        end

        # @return [Info] API metadata
        # @see Info
        def info
          @info ||= Info.new(@data[:info])
        end

        # @return [Array<Resource>] top-level resources
        # @see Resource
        def resources
          @resources ||= (@data[:resources] || {}).map do |name, data|
            Resource.new(name, data)
          end
        end

        # @return [Hash{Symbol => Resource}] resources indexed by name
        def resources_by_name
          @resources_by_name ||= resources.index_by(&:name)
        end

        # @return [Array<Type>] registered custom types
        # @see Type
        def types
          @types ||= (@data[:types] || {}).map do |name, data|
            Type.new(name, data)
          end
        end

        # @return [Hash{Symbol => Type}] types indexed by name
        def types_by_name
          @types_by_name ||= types.index_by(&:name)
        end

        # @return [Hash{Symbol => Hash}] raw types hash for mappers
        def types_hash
          @data[:types] || {}
        end

        # @return [Array<Enum>] registered enums
        # @see Enum
        def enums
          @enums ||= (@data[:enums] || {}).map do |name, data|
            Enum.new(name, data)
          end
        end

        # @return [Hash{Symbol => Enum}] enums indexed by name
        def enums_by_name
          @enums_by_name ||= enums.index_by(&:name)
        end

        # @return [Hash{Symbol => Hash}] raw enums hash for mappers
        def enums_hash
          @data[:enums] || {}
        end

        # @return [Array<Symbol>] API-level error codes that may be raised
        def raises
          @data[:raises] || []
        end

        # @return [Array<ErrorCode>] error code definitions
        # @see ErrorCode
        def error_codes
          @error_codes ||= (@data[:error_codes] || {}).map do |code, data|
            ErrorCode.new(code, data)
          end
        end

        # @return [Hash{Symbol => ErrorCode}] error codes indexed by code
        def error_codes_by_code
          @error_codes_by_code ||= error_codes.index_by(&:code)
        end

        # @return [Hash{Symbol => Hash}] raw error codes hash
        def error_codes_hash
          @data[:error_codes] || {}
        end

        # Iterates over all resources recursively (including nested).
        #
        # @yieldparam resource [Resource] the resource
        # @yieldparam parent_path [String, nil] parent resource path
        # @see Resource
        def each_resource(&block)
          iterate_resources(resources, nil, &block)
        end

        # @return [Hash] the raw underlying data hash
        def to_h
          @data
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
end
