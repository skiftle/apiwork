# frozen_string_literal: true

module Apiwork
  module Adapter
    module Builder
      module Contract
        # @api public
        # Base class for Contract-phase type builders.
        #
        # Contract phase runs once per bound contract at registration time.
        # Use it to generate contract-specific types based on the representation.
        #
        # @example
        #   class Builder
        #     class Contract < Adapter::Builder::Contract::Base
        #       def build
        #         object(representation_class.root_key.singular) do |object|
        #           # define resource shape
        #         end
        #       end
        #     end
        #   end
        class Base
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
          # Builds contract-level types.
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
