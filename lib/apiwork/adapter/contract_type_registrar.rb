# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api private
    class ContractTypeRegistrar
      attr_reader :contract_class

      def initialize(contract_class)
        @contract_class = contract_class
      end

      delegate :type, :enum, :union, :define_action, :import, to: :contract_class
    end
  end
end
