# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # Extension - Schema extension for Contract::Base
      # This module is prepended when schema() is called, providing schema-specific
      # functionality without polluting the base Contract class
      module Extension
        def self.prepended(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          # Override: Auto-generate and store a standard CRUD action (lazy loading)
          def auto_generate_and_store_action(action_name)
            action_definition = Generator.generate_action(schema_class, action_name)
            @action_definitions[action_name.to_sym] = action_definition if action_definition
          end
        end
      end
    end
  end
end
