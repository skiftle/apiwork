# frozen_string_literal: true

module Apiwork
  module Adapter
    module Builder
      module Contract
        # @api public
        # Base class for Contract-phase type builders.
        #
        # Contract phase runs once per contract with representation at registration time.
        # Use it to generate contract-specific types based on the representation.
        #
        # @example
        #   module Builder
        #     class Contract < Adapter::Builder::Contract::Base
        #       def build
        #         object(representation_class.singular_key_name) do |object|
        #           object.string(:id)
        #           object.string(:name)
        #         end
        #       end
        #     end
        #   end
        class Base
          attr_reader :representation_class

          # @!method api_class
          #   @api public
          #   @see Contract::Base.api_class
          # @!method enum(name, values:, **options, &block)
          #   @api public
          #   @see Contract::Base#enum
          # @!method enum?(name)
          #   @api public
          #   @see Contract::Base#enum?
          # @!method contract_for(representation_class)
          #   @api public
          #   @see Contract::Base.contract_for
          # @!method import(type_name, from:)
          #   @api public
          #   @see Contract::Base#import
          # @!method object(name, **options, &block)
          #   @api public
          #   @see Contract::Base#object
          # @!method scoped_enum_name(name)
          #   @api public
          #   @see Contract::Base#scoped_enum_name
          # @!method scoped_type_name(name)
          #   @api public
          #   @see Contract::Base#scoped_type_name
          # @!method type?(name)
          #   @api public
          #   @see Contract::Base#type?
          # @!method union(name, **options, &block)
          #   @api public
          #   @see Contract::Base#union
          delegate :api_class,
                   :contract_for,
                   :enum,
                   :enum?,
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
