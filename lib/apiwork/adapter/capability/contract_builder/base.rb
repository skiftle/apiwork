# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ContractBuilder
        class Base
          attr_reader :actions, :options, :schema_class

          delegate :action,
                   :api_registrar,
                   :ensure_association_types,
                   :enum,
                   :import,
                   :object,
                   :scoped_enum_name,
                   :scoped_type_name,
                   :type?,
                   :union,
                   to: :registrar

          def initialize(context)
            @registrar = context.registrar
            @schema_class = context.schema_class
            @actions = context.actions
            @options = context.options
          end

          def build
            raise NotImplementedError
          end

          def api
            @api ||= begin
              context = APIBuilder::Context.new(capabilities: nil, registrar: api_registrar)
              APIBuilder::Base.new(context)
            end
          end

          private

          attr_reader :registrar
        end
      end
    end
  end
end
