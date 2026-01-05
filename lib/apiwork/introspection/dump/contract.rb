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

          actions = available_actions
          actions = @contract_class.action_definitions.keys if actions.empty?

          actions.each do |action_name|
            action_definition = @contract_class.action_definition(action_name)
            result[:actions][action_name] = ActionDefinition.new(action_definition).to_h if action_definition
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
          @contract_class.api_class.type_system.types.each_pair
            .select { |_, metadata| metadata[:scope] == @contract_class }
            .sort_by { |name, _| name.to_s }
            .each_with_object({}) do |(name, metadata), result|
              result[name] = @type_dump.build_type(name, metadata)
          end
        end

        def build_local_enums
          @contract_class.api_class.type_system.enums.each_pair
            .select { |_, metadata| metadata[:scope] == @contract_class }
            .sort_by { |name, _| name.to_s }
            .each_with_object({}) do |(name, metadata), result|
              result[name] = @type_dump.build_enum(name, metadata)
          end
        end

        def build_referenced_types_and_enums(actions_data)
          type_system = @contract_class.api_class.type_system

          referenced_types = Set.new
          referenced_enums = Set.new
          dumped_types = {}
          processed_types = Set.new

          collect_references(actions_data, referenced_types, referenced_enums)

          until (pending_types = referenced_types - processed_types).empty?
            pending_types.each do |type_name|
              processed_types << type_name

              metadata = type_system.types[type_name]
              next unless metadata

              dumped = @type_dump.build_type(type_name, metadata)
              dumped_types[type_name] = dumped

              collect_references(dumped, referenced_types, referenced_enums)
            end
          end

          dumped_enums = referenced_enums.each_with_object({}) do |enum_name, result|
            metadata = type_system.enums[enum_name]
            result[enum_name] = @type_dump.build_enum(enum_name, metadata) if metadata
          end

          sorted_types = dumped_types.sort_by { |name, _| name.to_s }.to_h
          sorted_enums = dumped_enums.sort_by { |name, _| name.to_s }.to_h

          [sorted_types, sorted_enums]
        end

        def collect_references(data, types, enums)
          case data
          when Hash
            types << data[:ref].to_sym if data[:type] == :ref && data[:ref]

            of_data = data[:of]
            types << of_data[:ref].to_sym if of_data.is_a?(Hash) && of_data[:type] == :ref && of_data[:ref]

            enum_data = data[:enum]
            enums << enum_data[:ref].to_sym if enum_data.is_a?(Hash) && enum_data[:ref]

            data.each_value { |value| collect_references(value, types, enums) }
          when Array
            data.each { |item| collect_references(item, types, enums) }
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
