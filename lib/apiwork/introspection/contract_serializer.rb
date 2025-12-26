# frozen_string_literal: true

module Apiwork
  module Introspection
    class ContractSerializer
      def initialize(contract_class, expand: false)
        @contract_class = contract_class
        @expand = expand
      end

      def serialize
        @contract_class.api_class.ensure_all_contracts_built!

        result = { actions: {} }

        actions = available_actions
        actions = @contract_class.action_definitions.keys if actions.empty?

        actions.each do |action_name|
          action_definition = @contract_class.action_definition(action_name)
          result[:actions][action_name] = ActionSerializer.new(action_definition).serialize if action_definition
        end

        if @expand
          types, enums = serialize_referenced_types_and_enums(result[:actions])
        else
          types = serialize_local_types
          enums = serialize_local_enums
        end

        result[:types] = types if types.any?
        result[:enums] = enums if enums.any?

        result
      end

      private

      def serialize_local_types
        api_class = @contract_class.api_class
        return {} unless api_class

        type_serializer = TypeSerializer.new(api_class)

        api_class.type_system.types.each_pair
                 .select { |_, metadata| metadata[:scope] == @contract_class }
                 .sort_by { |name, _| name.to_s }
                 .each_with_object({}) do |(name, metadata), result|
          result[name] = type_serializer.serialize_type(name, metadata)
        end
      end

      def serialize_local_enums
        api_class = @contract_class.api_class
        return {} unless api_class

        type_serializer = TypeSerializer.new(api_class)

        api_class.type_system.enums.each_pair
                 .select { |_, metadata| metadata[:scope] == @contract_class }
                 .sort_by { |name, _| name.to_s }
                 .each_with_object({}) do |(name, metadata), result|
          result[name] = type_serializer.serialize_enum(name, metadata)
        end
      end

      def serialize_referenced_types_and_enums(actions_data)
        api_class = @contract_class.api_class
        return [{}, {}] unless api_class

        type_serializer = TypeSerializer.new(api_class)
        type_system = api_class.type_system

        referenced_types = Set.new
        referenced_enums = Set.new
        serialized_types = {}
        processed_types = Set.new

        collect_references(actions_data, referenced_types, referenced_enums)

        until (pending_types = referenced_types - processed_types).empty?
          pending_types.each do |type_name|
            processed_types << type_name

            metadata = type_system.types[type_name]
            next unless metadata

            serialized = type_serializer.serialize_type(type_name, metadata)
            serialized_types[type_name] = serialized

            collect_references(serialized, referenced_types, referenced_enums)
          end
        end

        serialized_enums = referenced_enums.each_with_object({}) do |enum_name, result|
          metadata = type_system.enums[enum_name]
          result[enum_name] = type_serializer.serialize_enum(enum_name, metadata) if metadata
        end

        sorted_types = serialized_types.sort_by { |name, _| name.to_s }.to_h
        sorted_enums = serialized_enums.sort_by { |name, _| name.to_s }.to_h

        [sorted_types, sorted_enums]
      end

      def collect_references(data, types, enums)
        case data
        when Hash
          type_ref = data[:type]
          types << type_ref.to_sym if type_ref && !primitive_type?(type_ref)

          of_ref = data[:of]
          types << of_ref.to_sym if of_ref && !primitive_type?(of_ref)

          enum_ref = data[:enum]
          enums << enum_ref.to_sym if enum_ref

          data.each_value { |v| collect_references(v, types, enums) }
        when Array
          data.each { |v| collect_references(v, types, enums) }
        end
      end

      def primitive_type?(type)
        Spec::TypeAnalysis.primitive_type?(type.to_sym)
      end

      def available_actions
        metadata = resource_metadata
        return [] unless metadata

        actions = metadata[:actions]&.keys || []
        actions += metadata[:members]&.keys || []
        actions += metadata[:collections]&.keys || []
        actions
      end

      def resource_metadata
        api = @contract_class.api_class
        return nil unless api&.metadata

        api.metadata.find_resource(resource_name)
      end

      def resource_name
        return nil unless @contract_class.name

        @contract_class.name.demodulize.delete_suffix('Contract').underscore.pluralize.to_sym
      end
    end
  end
end
