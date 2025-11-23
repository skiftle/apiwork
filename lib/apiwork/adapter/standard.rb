# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      def build_global_descriptors(builder)
        # No global descriptors needed for Standard adapter
        # All types are registered per-contract
      end

      def build_contract(contract_class, schema_data)
        schema_class = schema_data.schema_class

        Contract::Schema::TypeBuilder.build_contract_enums(contract_class, schema_class)

        contract_class.action_definitions.each do |action_name, action_definition|
          build_action(action_definition, action_name, schema_data)
        end
      end

      def build_action(action_definition, action_name, schema_data)
        schema_class = schema_data.schema_class
        contract_class = action_definition.contract_class

        case action_name.to_sym
        when :index
          build_index_action(action_definition, schema_class, contract_class)
        when :show
          build_show_action(action_definition, schema_class, contract_class)
        when :create
          build_create_action(action_definition, schema_class, contract_class)
        when :update
          build_update_action(action_definition, schema_class, contract_class)
        when :destroy
          build_destroy_action(action_definition, schema_class, contract_class)
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

      def build_action_request(action_definition, request_definition, action_name, schema_data)
        schema_class = schema_data.schema_class

        case action_name.to_sym
        when :index
          request_definition.query { ContractBuilder.generate_query_params(self, schema_class) }
        when :show
          add_include_query_param_if_needed(request_definition, schema_class)
        when :create
          request_definition.body { ContractBuilder.generate_writable_request(self, schema_class, :create) }
          add_include_query_param_if_needed(request_definition, schema_class)
        when :update
          request_definition.body { ContractBuilder.generate_writable_request(self, schema_class, :update) }
          add_include_query_param_if_needed(request_definition, schema_class)
        when :destroy
          # Destroy actions have no request params beyond routing params
        else
          add_include_query_param_if_needed(request_definition, schema_class) if member_action?(action_definition)
        end
      end

      def build_action_response(action_definition, response_definition, action_name, schema_data)
        schema_class = schema_data.schema_class

        case action_name.to_sym
        when :index
          response_definition.body { ContractBuilder.generate_collection_response(self, schema_class) }
        when :show, :create, :update
          response_definition.body { ContractBuilder.generate_single_response(self, schema_class) }
        when :destroy
          # Destroy actions return no response body (HTTP 204)
        else
          if collection_action?(action_definition)
            response_definition.body { ContractBuilder.generate_collection_response(self, schema_class) }
          elsif member_action?(action_definition)
            response_definition.body { ContractBuilder.generate_single_response(self, schema_class) }
          end
        end
      end

      def build_nested_writable_params(definition, schema_class, context, nested:)
        ContractBuilder.generate_writable_params(definition, schema_class, context, nested: nested)
      end

      private

      def build_index_action(action_definition, schema_class, contract_class)
        action_definition.request do
          query { ContractBuilder.generate_query_params(self, schema_class) }
        end
        action_definition.response do
          body { ContractBuilder.generate_collection_response(self, schema_class) }
        end
      end

      def build_show_action(action_definition, schema_class, contract_class)
        action_definition.request do
        end
        action_definition.response do
          body { ContractBuilder.generate_single_response(self, schema_class) }
        end
      end

      def build_create_action(action_definition, schema_class, contract_class)
        action_definition.request do
          body { ContractBuilder.generate_writable_request(self, schema_class, :create) }
        end
        action_definition.response do
          body { ContractBuilder.generate_single_response(self, schema_class) }
        end
      end

      def build_update_action(action_definition, schema_class, contract_class)
        action_definition.request do
          body { ContractBuilder.generate_writable_request(self, schema_class, :update) }
        end
        action_definition.response do
          body { ContractBuilder.generate_single_response(self, schema_class) }
        end
      end

      def build_destroy_action(action_definition, schema_class, contract_class)
        action_definition.response do
        end
      end

      def add_include_query_param_if_needed(request_def, schema_class)
        return unless schema_class.association_definitions.any?

        include_type = Contract::Schema::TypeBuilder.build_include_type(request_def.contract_class, schema_class)
        request_def.query { param :include, type: include_type, required: false }
      end

      def collection_action?(action_definition)
        return true if action_definition.action_name.to_sym == :index

        api = find_api_for_contract(action_definition.contract_class)
        return false unless api&.metadata

        api.metadata.search_resources do |resource_metadata|
          next unless resource_uses_contract?(resource_metadata, action_definition.contract_class)

          true if resource_metadata[:collections]&.key?(action_definition.action_name.to_sym)
        end || false
      end

      def member_action?(action_definition)
        return true if %i[show create update destroy].include?(action_definition.action_name.to_sym)

        api = find_api_for_contract(action_definition.contract_class)
        return false unless api&.metadata

        api.metadata.search_resources do |resource_metadata|
          next unless resource_uses_contract?(resource_metadata, action_definition.contract_class)

          true if resource_metadata[:members]&.key?(action_definition.action_name.to_sym)
        end || false
      end

      def resource_uses_contract?(resource_metadata, contract_class)
        resource_metadata[:contract_class] == contract_class
      end

      def find_api_for_contract(contract_class)
        contract_class.api_class
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
