# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Facade for introspected contract data.
    #
    # Provides access to actions, types, and enums defined on a contract.
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
      # @return [Hash{Symbol => Introspection::Action}] actions defined on this contract
      # @see Introspection::Action
      def actions
        @actions ||= @dump[:actions].transform_values { |dump| Action.new(dump) }
      end

      # @api public
      # @return [Hash{Symbol => Type}] custom types defined or referenced by this contract
      # @see Type
      def types
        @types ||= @dump[:types].transform_values { |dump| Type.new(dump) }
      end

      # @api public
      # @return [Hash{Symbol => Enum}] enums defined or referenced by this contract
      # @see Enum
      def enums
        @enums ||= @dump[:enums].transform_values { |dump| Enum.new(dump) }
      end

      # @api public
      # @return [Hash] structured representation
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
