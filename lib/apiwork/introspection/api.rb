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
    #   api = Apiwork::API.introspect('/api/v1', locale: :fr)
    #
    #   api.info.title                      # => "Mon API"
    #   api.types[:address].description     # => "Type d'adresse"
    #   api.enums[:status].values           # => ["draft", "published"]
    #
    #   api.resources.each_value do |resource|
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
      # @return [API::Info, nil] API metadata, or nil if not defined
      # @see API::Info
      def info
        return @info if defined?(@info)

        @info = @dump[:info] ? Info.new(@dump[:info]) : nil
      end

      # @api public
      # @return [Hash{Symbol => API::Resource}] top-level resources
      # @see API::Resource
      def resources
        @resources ||= @dump[:resources].transform_values { |dump| Resource.new(dump) }
      end

      # @api public
      # @return [Hash{Symbol => Type}] registered custom types
      # @see Type
      def types
        @types ||= @dump[:types].transform_values { |dump| Type.new(dump) }
      end

      # @api public
      # @return [Hash{Symbol => Enum}] registered enums
      # @see Enum
      def enums
        @enums ||= @dump[:enums].transform_values { |dump| Enum.new(dump) }
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
        @error_codes ||= @dump[:error_codes].transform_values { |dump| ErrorCode.new(dump) }
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        {
          enums: enums.transform_values(&:to_h),
          error_codes: error_codes.transform_values(&:to_h),
          info: info&.to_h,
          path: path,
          raises: raises,
          resources: resources.transform_values(&:to_h),
          types: types.transform_values(&:to_h),
        }
      end
    end
  end
end
