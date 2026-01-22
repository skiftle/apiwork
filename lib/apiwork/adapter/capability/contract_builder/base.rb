# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ContractBuilder
        class Base
          attr_reader :actions, :options, :schema_class

          delegate :action,
                   :enum,
                   :import,
                   :object,
                   :scoped_type_name,
                   :type?,
                   :union,
                   to: :contract_class

          def initialize(context)
            @schema_class = context.schema_class
            @actions = context.actions
            @options = context.options
            @contract_class = context.contract_class
          end

          def api
            @api ||= APIBuilder::Base.new(
              APIBuilder::Context.new(
                api_class: @contract_class.api_class,
                capabilities: nil,
              ),
            )
          end

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
