# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      def build_global_descriptors(builder, schema_data)
        DescriptorBuilder.new(builder, schema_data)
      end

      def build_contract(contract_class, schema_class, context)
        build_enums(contract_class, schema_class)

        context.actions.each do |action_name, action_info|
          build_action_definition(contract_class, schema_class, action_name, action_info)
        end
      end

      def collection_scope(collection, schema_class, query, context)
        return collection unless context.index?
        return collection unless collection.is_a?(ActiveRecord::Relation)

        Query.new(collection, schema: schema_class).perform(query)
      end

      def record_scope(record, schema_class, query, context)
        return record unless record.is_a?(ActiveRecord::Base)

        includes_param = query[:include]
        return record if includes_param.blank?

        includes_hash_value = build_includes_hash(schema_class, includes_param)
        return record if includes_hash_value.empty?

        ActiveRecord::Associations::Preloader.new(records: [record], associations: includes_hash_value).call
        record
      end

      def render_collection(collection, meta, query, schema_class, context)
        root_key = schema_class.root_key.plural

        response = { ok: true, root_key => collection }
        response[:meta] = meta if meta.present?
        response
      end

      def render_record(record, meta, query, schema_class, context)
        return { ok: true, meta: meta.presence || {} } if context.delete?

        root_key = schema_class.root_key.singular

        response = { ok: true, root_key => record }
        response[:meta] = meta if meta.present?
        response
      end

      def render_error(issues, context)
        { ok: false, issues: issues.map(&:to_h) }
      end

      def build_nested_writable_params(definition, schema_class, context, nested:)
        ContractBuilder.new(definition, schema_class).writable_params(context, nested: nested)
      end

      private

      def build_enums(contract_class, schema_class)
        schema_class.attribute_definitions.each do |name, attribute_definition|
          next unless attribute_definition.enum&.any?

          contract_class.register_enum(name, attribute_definition.enum)
        end
      end

      def build_action_definition(contract_class, schema_class, action_name, action_info)
        action_definition = contract_class.define_action(action_name)

        build_request_for_action(action_definition, schema_class, action_name, action_info) unless action_definition.resets_request?
        build_response_for_action(action_definition, schema_class, action_name, action_info) unless action_definition.resets_response?
      end

      def build_request_for_action(action_definition, schema_class, action_name, action_info)
        case action_name.to_sym
        when :index
          action_definition.request do
            query { ContractBuilder.new(self, schema_class).query_params }
          end
        when :show
          add_include_query_param_if_needed(action_definition, schema_class)
        when :create
          action_definition.request do
            body { ContractBuilder.new(self, schema_class).writable_request(:create) }
          end
          add_include_query_param_if_needed(action_definition, schema_class)
        when :update
          action_definition.request do
            body { ContractBuilder.new(self, schema_class).writable_request(:update) }
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
            body { ContractBuilder.new(self, schema_class).collection_response }
          end
        when :show, :create, :update
          action_definition.response do
            body { ContractBuilder.new(self, schema_class).single_response }
          end
        when :destroy
          action_definition.response do
            # Empty response for destroy
          end
        else
          if action_info[:type] == :collection
            action_definition.response do
              body { ContractBuilder.new(self, schema_class).collection_response }
            end
          elsif action_info[:type] == :member
            action_definition.response do
              body { ContractBuilder.new(self, schema_class).single_response }
            end
          end
        end
      end

      def add_include_query_param_if_needed(action_definition, schema_class)
        return unless schema_class.association_definitions.any?

        action_definition.request do
          query do
            include_type = Standard::TypeBuilder.build_include_type(contract_class, schema_class)
            param :include, type: include_type, required: false
          end
        end
      end

      def build_includes_hash(schema_class, includes_param)
        Query::IncludesResolver.new(schema: schema_class).build(
          params: { include: includes_param },
          for_collection: false
        )
      end
    end
  end
end
