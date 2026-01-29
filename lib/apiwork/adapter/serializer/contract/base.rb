# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Contract
        # @api public
        # Base class for serializer Contract phase.
        #
        # Contract phase runs once per bound contract at registration time.
        # Use it to generate contract-specific types based on the representation.
        #
        # @example
        #   class Contract < Serializer::Contract::Base
        #     def build
        #       object(representation_class.root_key.singular) do |o|
        #         # define resource shape
        #       end
        #     end
        #   end
        class Base
          # @api public
          # @return [Class] the representation class for this contract
          attr_reader :representation_class

          delegate :api_class,
                   :enum,
                   :enum?,
                   :find_contract_for_representation,
                   :import,
                   :object,
                   :scoped_enum_name,
                   :scoped_type_name,
                   :type?,
                   :union,
                   to: :contract_class

          def initialize(contract_class, representation_class)
            @contract_class = contract_class
            @representation_class = representation_class
          end

          # @api public
          # Builds contract-level types for this serializer.
          #
          # Override this method to generate types based on the representation.
          # @return [void]
          def build
            raise NotImplementedError
          end

          private

          attr_reader :contract_class
        end
      end
    end
  end
end
