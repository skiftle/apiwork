# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      class Generator
        class << self
          def generate_action(schema_class, action, contract_class:)
            return nil unless schema_class
            raise ArgumentError, 'contract_class is required' unless contract_class

            Apiwork::Contract::ActionDefinition.new(action_name: action, contract_class: contract_class)
          end

          def map_type(type)
            case type
            when :string, :text then :string
            when :integer then :integer
            when :boolean then :boolean
            when :datetime then :datetime
            when :date then :date
            when :time then :time
            when :uuid then :uuid
            when :decimal, :float then :decimal
            when :object then :object
            when :array then :array
            when :json, :jsonb then :object
            when :unknown then :unknown
            else :unknown
            end
          end
        end
      end
    end
  end
end
