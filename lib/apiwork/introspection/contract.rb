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
    #   contract.actions.each do |action|
    #     action.name      # => :index, :show, etc.
    #     action.request   # => Action::Request or nil
    #     action.response  # => Action::Response or nil
    #   end
    #
    #   contract.types.each { |t| ... }  # iterate custom types
    #   contract.enums.each { |e| ... }  # iterate enums
    class Contract
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # @return [Array<Action>] actions defined on this contract
      # @see Action
      def actions
        @actions ||= @dump[:actions].map do |action_name, action_data|
          Action.new(action_name, action_data)
        end
      end

      # @api public
      # @return [Array<Type>] custom types defined or referenced by this contract
      # @see Type
      def types
        @types ||= @dump[:types].map do |name, data|
          Type.new(name, data)
        end
      end

      # @api public
      # @return [Array<Enum>] enums defined or referenced by this contract
      # @see Enum
      def enums
        @enums ||= @dump[:enums].map do |name, data|
          Enum.new(name, data)
        end
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        {
          actions: actions.map(&:to_h),
          enums: enums.map(&:to_h),
          types: types.map(&:to_h),
        }
      end
    end
  end
end
