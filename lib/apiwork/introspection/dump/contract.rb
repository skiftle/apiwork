# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Contract
        def initialize(contract_class, expand: false)
          @contract_class = contract_class
          @expand = expand
          @type_dump = Type.new(contract_class.api_class)
        end

        def to_h
          @contract_class.api_class.ensure_all_contracts_built!

          result = { actions: {} }

          action_names = available_actions
          action_names = @contract_class.actions.keys if action_names.empty?

          action_names.each do |action_name|
            contract_action = @contract_class.action_for(action_name)
            result[:actions][action_name] = Action.new(contract_action).to_h if contract_action
          end

          if @expand
            types, enums = build_referenced_types_and_enums(result[:actions])
          else
            types = build_local_types
            enums = build_local_enums
          end

          result[:types] = types
          result[:enums] = enums

          result
        end

        private

        def build_local_types
          @contract_class.api_class.type_registry.each_pair
            .select { |_name, type_definition| type_definition.scope == @contract_class }
            .sort_by { |name, _type_definition| name.to_s }
            .each_with_object({}) do |(name, type_definition), result|
              result[name] = @type_dump.build_type(name, type_definition)
          end
        end

        def build_local_enums
          @contract_class.api_class.enum_registry.each_pair
            .select { |_name, enum_definition| enum_definition.scope == @contract_class }
            .sort_by { |name, _enum_definition| name.to_s }
            .each_with_object({}) do |(name, enum_definition), result|
              result[name] = @type_dump.build_enum(name, enum_definition)
          end
        end

        def build_referenced_types_and_enums(actions_dump)
          type_registry = @contract_class.api_class.type_registry
          enum_registry = @contract_class.api_class.enum_registry

          referenced_types = Set.new
          referenced_enums = Set.new
          dumped_types = {}
          processed_types = Set.new

          collect_references(actions_dump, referenced_types, referenced_enums)

          until (pending_types = referenced_types - processed_types).empty?
            pending_types.each do |type_name|
              processed_types << type_name

              type_definition = type_registry[type_name]
              next unless type_definition

              dumped = @type_dump.build_type(type_name, type_definition)
              dumped_types[type_name] = dumped

              collect_references(dumped, referenced_types, referenced_enums)
            end
          end

          dumped_enums = referenced_enums.each_with_object({}) do |enum_name, result|
            enum_definition = enum_registry[enum_name]
            result[enum_name] = @type_dump.build_enum(enum_name, enum_definition) if enum_definition
          end

          sorted_types = dumped_types.sort_by { |name, _type| name.to_s }.to_h
          sorted_enums = dumped_enums.sort_by { |name, _enum| name.to_s }.to_h

          [sorted_types, sorted_enums]
        end

        def collect_references(dump, types, enums)
          case dump
          when Hash
            types << dump[:ref].to_sym if dump[:type] == :ref && dump[:ref]

            of_dump = dump[:of]
            types << of_dump[:ref].to_sym if of_dump.is_a?(Hash) && of_dump[:type] == :ref && of_dump[:ref]

            enum_value = dump[:enum]
            enums << enum_value if enum_value.is_a?(Symbol)

            dump.each_value { |value| collect_references(value, types, enums) }
          when Array
            dump.each { |item| collect_references(item, types, enums) }
          end
        end

        def available_actions
          return [] unless resource

          resource.actions.keys
        end

        def resource
          api_class = @contract_class.api_class
          api_class.structure.find_resource(resource_name)
        end

        def resource_name
          return nil unless @contract_class.name

          @contract_class.name.demodulize.delete_suffix('Contract').underscore.pluralize.to_sym
        end
      end
    end
  end
end
