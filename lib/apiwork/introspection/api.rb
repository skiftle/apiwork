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
    #   api.info.title # => "Mon API"
    #   api.types[:address].description # => "Type d'adresse"
    #   api.enums[:status].values # => ["draft", "published"]
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
      # The base path for this API.
      #
      # @return [String, nil]
      def base_path
        @dump[:base_path]
      end

      # @api public
      # The info for this API.
      #
      # @return [API::Info, nil]
      def info
        @info ||= @dump[:info] ? Info.new(@dump[:info]) : nil
      end

      # @api public
      # The resources for this API.
      #
      # @return [Hash{Symbol => API::Resource}]
      def resources
        @resources ||= @dump[:resources].transform_values { |dump| Resource.new(dump) }
      end

      # @api public
      # The types for this API.
      #
      # @return [Hash{Symbol => Type}]
      def types
        @types ||= @dump[:types].transform_values { |dump| Type.new(dump) }
      end

      # @api public
      # The enums for this API.
      #
      # @return [Hash{Symbol => Enum}]
      def enums
        @enums ||= @dump[:enums].transform_values { |dump| Enum.new(dump) }
      end

      # @api public
      # The error codes for this API.
      #
      # @return [Hash{Symbol => ErrorCode}]
      def error_codes
        @error_codes ||= @dump[:error_codes].transform_values { |dump| ErrorCode.new(dump) }
      end

      # @api public
      # Converts this API to a hash.
      #
      # @return [Hash]
      def to_h
        {
          base_path:,
          enums: enums.transform_values(&:to_h),
          error_codes: error_codes.transform_values(&:to_h),
          info: info&.to_h,
          resources: resources.transform_values(&:to_h),
          types: types.transform_values(&:to_h),
        }
      end
    end
  end
end
