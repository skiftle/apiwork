# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class ContractBuilder
        MAX_RECURSION_DEPTH = 3

        def self.build(contract_class, schema_class, actions)
          new(contract_class, schema_class, actions)
        end

        def initialize(contract_class, schema_class, actions)
          @contract_class = contract_class
          @schema_class = schema_class
          @actions = actions

          build_enums
          build_actions
        end

        private

        attr_reader :actions,
                    :contract_class,
                    :schema_class

        def query_params(definition)
          filter_type = build_filter_type
          sort_type = build_sort_type

          if filter_type
            definition.param :filter, type: :union, required: false do
              variant type: filter_type
              variant type: :array, of: filter_type
            end
          end

          if sort_type
            definition.param :sort, type: :union, required: false do
              variant type: sort_type
              variant type: :array, of: sort_type
            end
          end

          page_type = build_page_type
          definition.param :page, type: page_type, required: false

          include_type = build_include_type
          definition.param :include, type: include_type, required: false
        end

        def writable_request(definition, context_symbol)
          root_key = schema_class.root_key.singular.to_sym
          builder = self

          if sti_base_schema?
            payload_type_name = sti_request_union(context_symbol)
          else
            payload_type_name = :"#{context_symbol}_payload"

            unless contract_class.resolve_type(payload_type_name)
              contract_class.type(payload_type_name) do
                builder.send(:writable_params, self, context_symbol, nested: false)
              end
            end
          end

          definition.param root_key, type: payload_type_name, required: true
        end

        def writable_params(definition, context_symbol, nested: false)
          schema_class.attribute_definitions.each do |name, attribute_definition|
            next unless attribute_definition.writable_for?(context_symbol)

            param_options = {
              type: map_type(attribute_definition.type),
              required: attribute_definition.required?,
              nullable: attribute_definition.nullable?,
              description: attribute_definition.description,
              example: attribute_definition.example,
              format: attribute_definition.format,
              deprecated: attribute_definition.deprecated,
              attribute_definition: attribute_definition
            }

            param_options[:min] = attribute_definition.min if attribute_definition.min
            param_options[:max] = attribute_definition.max if attribute_definition.max

            param_options[:enum] = name if attribute_definition.enum

            definition.param name, **param_options
          end

          schema_class.association_definitions.each do |name, association_definition|
            next unless association_definition.writable_for?(context_symbol)

            association_schema = resolve_association_resource(association_definition)
            association_payload_type = nil

            association_contract = nil
            if association_schema
              import_alias = import_association_contract(association_schema, Set.new)

              if import_alias
                association_payload_type = :"#{import_alias}_nested_payload"

                association_contract = contract_class.find_contract_for_schema(association_schema)
              end
            end

            param_options = {
              required: false,
              nullable: association_definition.nullable?,
              as: "#{name}_attributes".to_sym,
              description: association_definition.description,
              example: association_definition.example,
              deprecated: association_definition.deprecated
            }

            param_options[:type_contract_class] = association_contract if association_contract

            if association_payload_type
              if association_definition.collection?
                param_options[:type] = :array
                param_options[:of] = association_payload_type
              else
                param_options[:type] = association_payload_type
              end
            else
              param_options[:type] = association_definition.collection? ? :array : :object
            end

            definition.param name, **param_options
          end
        end

        def single_response(definition)
          root_key = schema_class.root_key.singular.to_sym
          resource_type_name = resource_type_name_for_response

          definition.instance_variable_set(:@unwrapped_union, true)

          definition.param root_key, type: resource_type_name, required: true
          definition.param :meta, type: :object, required: false

          definition.param :issues, type: :array, of: :issue, required: false
        end

        def collection_response(definition)
          root_key_plural = schema_class.root_key.plural.to_sym
          resource_type_name = resource_type_name_for_response
          pagination_type = build_pagination_type

          definition.instance_variable_set(:@unwrapped_union, true)

          definition.param root_key_plural, type: :array, of: resource_type_name, required: false
          definition.param :pagination, type: pagination_type, required: false
          definition.param :meta, type: :object, required: false

          definition.param :issues, type: :array, of: :issue, required: false
        end

        def build_enums
          schema_class.attribute_definitions.each do |name, attribute_definition|
            next unless attribute_definition.enum&.any?

            contract_class.enum(name, values: attribute_definition.enum)
          end
        end

        def build_actions
          actions.each do |action_name, action_info|
            build_action_definition(action_name, action_info)
          end
        end

        def build_action_definition(action_name, action_info)
          action_definition = contract_class.define_action(action_name)

          build_request_for_action(action_definition, action_name, action_info) unless action_definition.resets_request?
          build_response_for_action(action_definition, action_name, action_info) unless action_definition.resets_response?
        end

        def build_request_for_action(action_definition, action_name, action_info)
          builder = self

          case action_name.to_sym
          when :index
            action_definition.request do
              query { builder.send(:query_params, self) }
            end
          when :show
            add_include_query_param_if_needed(action_definition)
          when :create
            action_definition.request do
              body { builder.send(:writable_request, self, :create) }
            end
            add_include_query_param_if_needed(action_definition)
          when :update
            action_definition.request do
              body { builder.send(:writable_request, self, :update) }
            end
            add_include_query_param_if_needed(action_definition)
          when :destroy
            nil
          else
            add_include_query_param_if_needed(action_definition) if action_info[:type] == :member
          end
        end

        def build_response_for_action(action_definition, action_name, action_info)
          builder = self

          case action_name.to_sym
          when :index
            action_definition.response do
              body { builder.send(:collection_response, self) }
            end
          when :show, :create, :update
            action_definition.response do
              body { builder.send(:single_response, self) }
            end
          when :destroy
            action_definition.response {}
          else
            if action_info[:type] == :collection
              action_definition.response do
                body { builder.send(:collection_response, self) }
              end
            elsif action_info[:type] == :member
              action_definition.response do
                body { builder.send(:single_response, self) }
              end
            end
          end
        end

        def add_include_query_param_if_needed(action_definition)
          return unless schema_class.association_definitions.any?

          schema_class
          builder = self

          action_definition.request do
            query do
              include_type = builder.send(:build_include_type)
              param :include, type: include_type, required: false
            end
          end
        end

        def sti_request_union(context_symbol)
          union_type_name = :"#{context_symbol}_payload"
          discriminator_name = schema_class.discriminator_name
          builder = self

          build_sti_union(union_type_name: union_type_name) do |contract, variant_schema, tag, _visited|
            variant_schema_name = variant_schema.name.demodulize.underscore.gsub(/_schema$/, '')
            variant_type_name = :"#{variant_schema_name}_#{context_symbol}_payload"

            unless contract.resolve_type(variant_type_name)
              contract.type(variant_type_name) do
                param discriminator_name, type: :literal, value: tag.to_s, required: true

                builder.send(:writable_params, self, context_symbol, nested: false)
              end
            end

            contract.scoped_type_name(variant_type_name)
          end
        end

        def resource_type_name_for_response
          if sti_base_schema?
            build_sti_response_union_type
          else
            root_key = schema_class.root_key.singular.to_sym
            resource_type_name = contract_class.scoped_type_name(nil)

            register_resource_type(root_key) unless contract_class.resolve_type(resource_type_name)

            resource_type_name
          end
        end

        def register_resource_type(type_name)
          assoc_type_map = {}
          schema_class.association_definitions.each do |name, association_definition|
            assoc_type_map[name] = build_association_type(association_definition)
          end

          build_enums

          schema_class_local = schema_class
          builder = self
          contract_class.type(type_name) do
            schema_class_local.attribute_definitions.each do |name, attribute_definition|
              enum_option = attribute_definition.enum ? { enum: name } : {}

              param name,
                    type: builder.send(:map_type, attribute_definition.type),
                    required: false,
                    description: attribute_definition.description,
                    example: attribute_definition.example,
                    format: attribute_definition.format,
                    deprecated: attribute_definition.deprecated,
                    **enum_option
            end

            schema_class_local.association_definitions.each do |name, association_definition|
              assoc_type = assoc_type_map[name]

              base_options = {
                required: association_definition.always_included?,
                nullable: association_definition.nullable?,
                description: association_definition.description,
                example: association_definition.example,
                deprecated: association_definition.deprecated
              }

              if association_definition.singular?
                param name, type: assoc_type || :object, **base_options
              elsif association_definition.collection?
                if assoc_type
                  param name, type: :array, of: assoc_type, **base_options
                else
                  param name, type: :array, **base_options
                end
              end
            end
          end
        end

        def build_filter_type(visited: Set.new, depth: 0)
          return nil if visited.include?(schema_class)
          return nil if depth >= MAX_RECURSION_DEPTH

          visited = visited.dup.add(schema_class)

          type_name = type_name(:filter, depth)

          existing = contract_class.resolve_type(type_name)
          return type_name if existing

          builder = self
          schema_class_local = schema_class

          contract_class.type(type_name) do
            param :_and, type: :array, of: type_name, required: false
            param :_or, type: :array, of: type_name, required: false
            param :_not, type: type_name, required: false

            schema_class_local.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.filterable?
              next if attribute_definition.type == :unknown

              filter_type = builder.send(:filter_type_for, attribute_definition)

              if attribute_definition.enum
                param name, type: filter_type, required: false
              else
                param name, type: :union, required: false do
                  variant type: builder.send(:map_type, attribute_definition.type)
                  variant type: filter_type
                end
              end
            end

            schema_class_local.association_definitions.each do |name, association_definition|
              next unless association_definition.filterable?

              association_resource = builder.send(:resolve_association_resource, association_definition)
              next unless association_resource
              next if visited.include?(association_resource)

              import_alias = builder.send(:import_association_contract, association_resource, visited)

              association_filter_type = if import_alias
                                          :"#{import_alias}_filter"
                                        else
                                          builder.send(:build_filter_type_for_schema,
                                                       association_resource,
                                                       visited: visited,
                                                       depth: depth + 1)
                                        end

              param name, type: association_filter_type, required: false if association_filter_type
            end
          end

          type_name
        end

        def build_filter_type_for_schema(assoc_schema, visited:, depth:)
          temp_builder = self.class.allocate
          temp_builder.instance_variable_set(:@contract_class, contract_class)
          temp_builder.instance_variable_set(:@schema_class, assoc_schema)
          temp_builder.instance_variable_set(:@context, nil)
          temp_builder.send(:build_filter_type, visited: visited, depth: depth)
        end

        def build_sort_type(visited: Set.new, depth: 0)
          return nil if visited.include?(schema_class)
          return nil if depth >= MAX_RECURSION_DEPTH

          visited = visited.dup.add(schema_class)

          type_name = type_name(:sort, depth)

          existing = contract_class.resolve_type(type_name)
          return type_name if existing

          builder = self
          schema_class_local = schema_class

          contract_class.type(type_name) do
            schema_class_local.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.sortable?

              param name, type: :sort_direction, required: false
            end

            schema_class_local.association_definitions.each do |name, association_definition|
              next unless association_definition.sortable?

              association_resource = builder.send(:resolve_association_resource, association_definition)
              next unless association_resource
              next if visited.include?(association_resource)

              import_alias = builder.send(:import_association_contract, association_resource, visited)

              association_sort_type = if import_alias
                                        :"#{import_alias}_sort"
                                      else
                                        builder.send(:build_sort_type_for_schema,
                                                     association_resource,
                                                     visited: visited,
                                                     depth: depth + 1)
                                      end

              param name, type: association_sort_type, required: false if association_sort_type
            end
          end

          type_name
        end

        def build_sort_type_for_schema(assoc_schema, visited:, depth:)
          temp_builder = self.class.allocate
          temp_builder.instance_variable_set(:@contract_class, contract_class)
          temp_builder.instance_variable_set(:@schema_class, assoc_schema)
          temp_builder.instance_variable_set(:@context, nil)
          temp_builder.send(:build_sort_type, visited: visited, depth: depth)
        end

        def build_page_type
          strategy = schema_class.resolve_option(:pagination, :strategy)
          max_size = schema_class.resolve_option(:pagination, :max_size)

          type_name = type_name(:page, 1)

          existing = contract_class.resolve_type(type_name)
          return type_name if existing

          if strategy == :cursor
            contract_class.global_type(type_name) do
              param :after, type: :string, required: false
              param :before, type: :string, required: false
              param :size, type: :integer, required: false, min: 1, max: max_size
            end
          else
            contract_class.global_type(type_name) do
              param :number, type: :integer, required: false, min: 1
              param :size, type: :integer, required: false, min: 1, max: max_size
            end
          end

          type_name
        end

        def build_pagination_type
          strategy = schema_class.resolve_option(:pagination, :strategy)
          strategy == :cursor ? :cursor_pagination : :page_pagination
        end

        def build_include_type(visited: Set.new, depth: 0)
          type_name = type_name(:include, depth)

          existing = contract_class.resolve_type(type_name)
          return type_name if existing
          return type_name if depth >= MAX_RECURSION_DEPTH

          visited = visited.dup.add(schema_class)

          builder = self
          schema_class_local = schema_class

          contract_class.type(type_name) do
            schema_class_local.association_definitions.each do |name, association_definition|
              association_resource = builder.send(:resolve_association_resource, association_definition)
              next unless association_resource

              is_sti = association_resource.is_a?(Hash) && association_resource[:sti]
              actual_schema = is_sti ? association_resource[:schema] : association_resource

              if visited.include?(actual_schema)
                param name, type: :boolean, required: false unless association_definition.always_included?
              else
                import_alias = builder.send(:import_association_contract, actual_schema, visited)

                association_include_type = if import_alias
                                             :"#{import_alias}_include"
                                           else
                                             builder.send(:build_include_type_for_schema,
                                                          actual_schema,
                                                          visited: visited,
                                                          depth: depth + 1)
                                           end

                if association_definition.always_included?
                  param name, type: association_include_type, required: false
                else
                  param name, type: :union, required: false do
                    variant type: :boolean
                    variant type: association_include_type
                  end
                end
              end
            end
          end

          type_name
        end

        def build_include_type_for_schema(assoc_schema, visited:, depth:)
          temp_builder = self.class.allocate
          temp_builder.instance_variable_set(:@contract_class, contract_class)
          temp_builder.instance_variable_set(:@schema_class, assoc_schema)
          temp_builder.instance_variable_set(:@context, nil)
          temp_builder.send(:build_include_type, visited: visited, depth: depth)
        end

        def build_nested_payload_union
          return unless schema_class.attribute_definitions.any? { |_, ad| ad.writable? } ||
                        schema_class.association_definitions.any? { |_, ad| ad.writable? }

          create_type_name = :nested_create_payload
          builder = self
          schema = schema_class

          unless contract_class.resolve_type(create_type_name)
            contract_class.type(create_type_name) do
              param :_type, type: :literal, value: 'create', required: true
              builder.send(:writable_params, self, :create, nested: true)
              param :_destroy, type: :boolean, required: false if schema.association_definitions.any? { |_, ad| ad.writable? && ad.allow_destroy }
            end
          end

          update_type_name = :nested_update_payload
          unless contract_class.resolve_type(update_type_name)
            contract_class.type(update_type_name) do
              param :_type, type: :literal, value: 'update', required: true
              builder.send(:writable_params, self, :update, nested: true)
              param :_destroy, type: :boolean, required: false if schema.association_definitions.any? { |_, ad| ad.writable? && ad.allow_destroy }
            end
          end

          nested_payload_type_name = :nested_payload
          return if contract_class.resolve_type(nested_payload_type_name)

          create_qualified_name = contract_class.scoped_type_name(create_type_name)
          update_qualified_name = contract_class.scoped_type_name(update_type_name)

          contract_class.build_union(nested_payload_type_name, discriminator: :_type) do |union|
            union.variant(type: create_qualified_name, tag: 'create')
            union.variant(type: update_qualified_name, tag: 'update')
          end
        end

        def build_response_type(visited: Set.new)
          return if visited.include?(schema_class)

          visited = visited.dup.add(schema_class)

          return if sti_base_schema?

          root_key = schema_class.root_key.singular.to_sym
          resource_type_name = contract_class.scoped_type_name(nil)

          return if contract_class.resolve_type(resource_type_name)

          build_enums

          builder = self
          schema_class_local = schema_class

          contract_class.type(root_key) do
            if schema_class_local.respond_to?(:sti_variant?) && schema_class_local.sti_variant?
              parent_schema = schema_class_local.superclass
              discriminator_name = parent_schema.discriminator_name
              variant_tag = schema_class_local.variant_tag.to_s

              param discriminator_name, type: :literal, value: variant_tag, required: true
            end

            assoc_type_map = {}
            schema_class_local.association_definitions.each do |name, association_definition|
              result = builder.send(:build_association_type, association_definition, visited: visited)
              assoc_type_map[name] = result
            end

            schema_class_local.attribute_definitions.each do |name, attribute_definition|
              enum_option = attribute_definition.enum ? { enum: name } : {}
              param name,
                    type: builder.send(:map_type, attribute_definition.type),
                    required: false,
                    description: attribute_definition.description,
                    example: attribute_definition.example,
                    format: attribute_definition.format,
                    deprecated: attribute_definition.deprecated,
                    **enum_option
            end

            schema_class_local.association_definitions.each do |name, association_definition|
              assoc_type = assoc_type_map[name]
              is_required = association_definition.always_included?

              if assoc_type
                if association_definition.singular?
                  param name, type: assoc_type, required: is_required, nullable: association_definition.nullable?
                elsif association_definition.collection?
                  param name, type: :array, of: assoc_type, required: is_required,
                              nullable: association_definition.nullable?
                end
              elsif association_definition.singular?
                param name, type: :object, required: is_required, nullable: association_definition.nullable?
              elsif association_definition.collection?
                param name, type: :array, of: :object, required: is_required, nullable: association_definition.nullable?
              end
            end
          end
        end

        def build_association_type(association_definition, visited: Set.new)
          return build_polymorphic_association_type(association_definition, visited: visited) if association_definition.polymorphic?

          association_schema = resolve_association_resource(association_definition)
          return nil unless association_schema

          if association_schema.is_a?(Hash) && association_schema[:sti]
            return build_sti_association_type(association_definition, association_schema[:schema], visited: visited)
          end

          return nil if visited.include?(association_schema)

          import_alias = import_association_contract(association_schema, visited)
          return import_alias if import_alias

          nil
        end

        def build_polymorphic_association_type(association_definition, visited: Set.new)
          polymorphic = association_definition.polymorphic
          return nil unless polymorphic&.any?

          union_type_name = :"#{association_definition.name}_polymorphic"

          existing = contract_class.resolve_type(union_type_name)
          return existing if existing

          builder = self

          contract_class.build_union(union_type_name, discriminator: association_definition.discriminator) do |union|
            polymorphic.each do |tag, schema_class|
              import_alias = builder.send(:import_association_contract, schema_class, visited)
              next unless import_alias

              union.variant(type: import_alias, tag: tag.to_s)
            end
          end
        end

        def build_sti_union(union_type_name:, visited: Set.new, &variant_builder)
          variants = schema_class.variants
          return nil unless variants&.any?

          discriminator_name = schema_class.discriminator_name

          contract_class.build_union(union_type_name, discriminator: discriminator_name) do |union|
            variants.each do |tag, variant_data|
              variant_schema = variant_data[:schema]

              variant_type = yield(contract_class, variant_schema, tag, visited)
              next unless variant_type

              union.variant(type: variant_type, tag: tag.to_s)
            end
          end
        end

        def build_sti_association_type(association_definition, schema_class_arg, visited: Set.new)
          union_type_name = :"#{association_definition.name}_sti"

          temp_builder = self.class.allocate
          temp_builder.instance_variable_set(:@contract_class, contract_class)
          temp_builder.instance_variable_set(:@schema_class, schema_class_arg)
          temp_builder.instance_variable_set(:@context, nil)

          temp_builder.send(:build_sti_union, union_type_name: union_type_name,
                                              visited: visited) do |_contract, variant_schema, _tag, visit_set|
            temp_builder.send(:import_association_contract, variant_schema, visit_set)
          end
        end

        def build_sti_response_union_type(visited: Set.new)
          union_type_name = schema_class.root_key.singular.to_sym

          builder = self

          build_sti_union(union_type_name: union_type_name, visited: visited) do |_contract, variant_schema, _tag, visit_set|
            builder.send(:import_association_contract, variant_schema, visit_set)
          end
        end

        def determine_filter_type(attr_type, nullable: false)
          base_type = case attr_type
                      when :string
                        :string_filter
                      when :date
                        :date_filter
                      when :datetime
                        :datetime_filter
                      when :integer
                        :integer_filter
                      when :decimal, :float
                        :decimal_filter
                      when :uuid
                        :uuid_filter
                      when :boolean
                        :boolean_filter
                      else
                        :string_filter
                      end

          nullable ? :"nullable_#{base_type}" : base_type
        end

        def filter_type_for(attribute_definition)
          return enum_filter_type(attribute_definition) if attribute_definition.enum

          determine_filter_type(attribute_definition.type, nullable: attribute_definition.nullable?)
        end

        def enum_filter_type(attribute_definition)
          scoped_enum_name = contract_class.scoped_enum_name(attribute_definition.name)
          :"#{scoped_enum_name}_filter"
        end

        def sti_base_schema?
          return false unless schema_class.respond_to?(:sti_base?) && schema_class.sti_base?

          schema_class.respond_to?(:variants) && schema_class.variants&.any?
        end

        def resolve_association_resource(association_definition)
          return :polymorphic if association_definition.polymorphic?

          if association_definition.schema_class
            resolved_schema = if association_definition.schema_class.is_a?(Class)
                                association_definition.schema_class
                              else
                                begin
                                  association_definition.schema_class.constantize
                                rescue NameError
                                  nil
                                end
                              end

            return { sti: true, schema: resolved_schema } if resolved_schema.respond_to?(:sti_base?) && resolved_schema.sti_base?

            return resolved_schema
          end

          model_class = association_definition.model_class
          return nil unless model_class

          reflection = model_class.reflect_on_association(association_definition.name)
          return nil unless reflection

          resolved_schema = Schema::Base.resolve_association_schema(reflection, schema_class)
          return nil unless resolved_schema

          return { sti: true, schema: resolved_schema } if resolved_schema.respond_to?(:sti_base?) && resolved_schema.sti_base?

          resolved_schema
        end

        def import_association_contract(association_schema, visited)
          return nil if visited.include?(association_schema)

          association_contract = contract_class.find_contract_for_schema(association_schema)

          unless association_contract
            contract_name = association_schema.name.sub(/Schema$/, 'Contract')
            association_contract = begin
              contract_name.constantize
            rescue StandardError
              nil
            end
          end

          return nil unless association_contract

          alias_name = association_schema.root_key.singular.to_sym

          contract_class.import(association_contract, as: alias_name) unless contract_class.imports.key?(alias_name)

          if association_contract.schema?
            api_class = association_contract.api_class
            api_class&.ensure_contract_built!(association_contract)

            temp_builder = self.class.allocate
            temp_builder.instance_variable_set(:@contract_class, association_contract)
            temp_builder.instance_variable_set(:@schema_class, association_schema)
            temp_builder.instance_variable_set(:@context, nil)

            temp_builder.send(:build_filter_type, visited: Set.new, depth: 0)
            temp_builder.send(:build_sort_type, visited: Set.new, depth: 0)
            temp_builder.send(:build_include_type, visited: Set.new, depth: 0)
            temp_builder.send(:build_nested_payload_union)
            temp_builder.send(:build_response_type, visited: Set.new)
          end

          alias_name
        end

        def type_name(base_name, depth)
          return base_name if depth.zero?

          schema_name = schema_class.name.demodulize.underscore.gsub(/_schema$/, '')
          :"#{schema_name}_#{base_name}"
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
