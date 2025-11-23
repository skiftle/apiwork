# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      def build_global_descriptors(builder)
        # No global descriptors needed for Standard adapter
        # All types are registered per-contract
      end

      def build_contract(contract_class, actions, schema_data, metadata, api_class)
        schema_class = schema_data.schema_class

        build_enums(contract_class, schema_class, api_class)

        actions.each do |action_name, action_info|
          build_action_definition(contract_class, schema_class, action_name, action_info)
        end
      end

      def collection_scope(collection, schema_data, query, metadata)
        return collection unless metadata.index?
        return collection unless collection.is_a?(ActiveRecord::Relation)

        Query.new(collection, schema: schema_data.schema_class).perform(query)
      end

      def record_scope(record, schema_data, query, metadata)
        return record unless record.is_a?(ActiveRecord::Base)

        includes_param = query[:include]
        return record if includes_param.blank?

        includes_hash_value = build_includes_hash(schema_data, includes_param)
        return record if includes_hash_value.empty?

        ActiveRecord::Associations::Preloader.new(records: [record], associations: includes_hash_value).call
        record
      end

      def render_collection(collection, meta, query, metadata)
        root_key = metadata.schema_data.root_key.plural

        response = { ok: true, root_key => collection }
        response[:meta] = meta if meta.present?
        response
      end

      def render_record(record, meta, query, metadata)
        return { ok: true, meta: meta.presence || {} } if metadata.delete?

        root_key = metadata.schema_data.root_key.singular

        response = { ok: true, root_key => record }
        response[:meta] = meta if meta.present?
        response
      end

      def render_errors(issues, metadata)
        { ok: false, issues: issues.map(&:to_h) }
      end

      def build_nested_writable_params(definition, schema_class, context, nested:)
        ContractBuilder.generate_writable_params(definition, schema_class, context, nested: nested)
      end

      private

      def build_enums(contract_class, schema_class, api_class)
        schema_class.attribute_definitions.each do |name, attribute_definition|
          next unless attribute_definition.enum&.any?

          Descriptor.register_enum(name, attribute_definition.enum, scope: contract_class, api_class: api_class)
        end
      end

      def build_action_definition(contract_class, schema_class, action_name, action_info)
        existing_action = contract_class.action_definitions[action_name]

        if existing_action
          action_definition = existing_action
        else
          action_definition = Contract::ActionDefinition.new(
            action_name: action_name,
            contract_class: contract_class
          )
          contract_class.action_definitions[action_name] = action_definition
        end

        build_request_for_action(action_definition, schema_class, action_name, action_info) unless existing_action&.resets_request?
        build_response_for_action(action_definition, schema_class, action_name, action_info) unless existing_action&.resets_response?
      end

      def build_request_for_action(action_definition, schema_class, action_name, action_info)
        case action_name.to_sym
        when :index
          action_definition.request do
            query { ContractBuilder.generate_query_params(self, schema_class) }
          end
        when :show
          add_include_query_param_if_needed(action_definition, schema_class)
        when :create
          action_definition.request do
            body { ContractBuilder.generate_writable_request(self, schema_class, :create) }
          end
          add_include_query_param_if_needed(action_definition, schema_class)
        when :update
          action_definition.request do
            body { ContractBuilder.generate_writable_request(self, schema_class, :update) }
          end
          add_include_query_param_if_needed(action_definition, schema_class)
        when :destroy
          # Destroy has no request params
        else
          if action_info[:type] == :collection
            # Custom collection action - might need query params
          elsif action_info[:type] == :member
            # Custom member action
            add_include_query_param_if_needed(action_definition, schema_class)
          end
        end
      end

      def build_response_for_action(action_definition, schema_class, action_name, action_info)
        case action_name.to_sym
        when :index
          action_definition.response do
            body { ContractBuilder.generate_collection_response(self, schema_class) }
          end
        when :show, :create, :update
          action_definition.response do
            body { ContractBuilder.generate_single_response(self, schema_class) }
          end
        when :destroy
          action_definition.response do
            # Empty response for destroy
          end
        else
          if action_info[:type] == :collection
            action_definition.response do
              body { ContractBuilder.generate_collection_response(self, schema_class) }
            end
          elsif action_info[:type] == :member
            action_definition.response do
              body { ContractBuilder.generate_single_response(self, schema_class) }
            end
          end
        end
      end

      def add_include_query_param_if_needed(action_definition, schema_class)
        return unless schema_class.association_definitions.any?

        action_definition.request do
          query do
            include_type = Contract::Schema::TypeBuilder.build_include_type(contract_class, schema_class)
            param :include, type: include_type, required: false
          end
        end
      end

      def build_includes_hash(schema_data, includes_param)
        Query::IncludesResolver.new(schema: schema_data.schema_class).build(
          params: { include: includes_param },
          for_collection: false
        )
      end
    end
  end
end
