# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Facade for introspected contract data.
    #
    # Provides access to actions, types, and enums defined on this contract.
    #
    # @example
    #   contract = InvoiceContract.introspect(expand: true)
    #
    #   contract.actions[:show].response  # => Action::Response
    #   contract.types[:address].shape    # => { street: ..., city: ... }
    #   contract.enums[:status].values    # => ["draft", "published"]
    #
    #   contract.actions.each_value do |action|
    #     action.request   # => Action::Request
    #     action.response  # => Action::Response
    #   end
    class Contract
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # Actions defined on this contract.
      # @return [Hash{Symbol => Introspection::Action}]
      # @see Introspection::Action
      def actions
        @actions ||= @dump[:actions].transform_values { |dump| Action.new(dump) }
      end

      # @api public
      # Custom types defined or referenced by this contract.
      # @return [Hash{Symbol => Type}]
      # @see Type
      def types
        @types ||= @dump[:types].transform_values { |dump| Type.new(dump) }
      end

      # @api public
      # Enums defined or referenced by this contract.
      # @return [Hash{Symbol => Enum}]
      # @see Enum
      def enums
        @enums ||= @dump[:enums].transform_values { |dump| Enum.new(dump) }
      end

      # @api public
      # Converts this contract to a hash.
      #
      # @return [Hash]
      def to_h
        {
          actions: actions.transform_values(&:to_h),
          enums: enums.transform_values(&:to_h),
          types: types.transform_values(&:to_h),
        }
      end
    end
  end
end
