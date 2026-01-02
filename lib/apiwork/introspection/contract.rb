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
    #     action.request   # => Action::Request or nil
    #     action.response  # => Action::Response or nil
    #   end
    class Contract
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # @return [Hash{Symbol => Action}] actions defined on this contract
      # @see Action
      def actions
        @actions ||= @dump[:actions].transform_values { |data| Action.new(data) }
      end

      # @api public
      # @return [Hash{Symbol => Type}] custom types defined or referenced by this contract
      # @see Type
      def types
        @types ||= @dump[:types].transform_values { |data| Type.new(data) }
      end

      # @api public
      # @return [Hash{Symbol => Enum}] enums defined or referenced by this contract
      # @see Enum
      def enums
        @enums ||= @dump[:enums].transform_values { |data| Enum.new(data) }
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
