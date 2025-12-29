# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
      class ContractBuilder
        MAX_RECURSION_DEPTH = 3

        def self.build(registrar, schema_class, actions)
          new(registrar, schema_class, actions: actions, build: true)
        end

        def self.for_schema(registrar, schema_class)
          new(registrar, schema_class)
        end

        def initialize(registrar, schema_class, actions: nil, build: false)
          @registrar = registrar
          @schema_class = schema_class
          @actions = actions

          return unless build

          build_enums
          build_actions
        end

        def single_response(param_definition)
          root_key = schema_class.root_key.singular.to_sym
          resource_type_name = resource_type_name_for_response

          param_definition.param root_key, type: resource_type_name
          param_definition.param :meta, optional: true, type: :object
        end

        def collection_response(param_definition)
          root_key_plural = schema_class.root_key.plural.to_sym
          resource_type_name = resource_type_name_for_response
          pagination_type = build_pagination_type

          param_definition.param root_key_plural, of: resource_type_name, type: :array
          param_definition.param :pagination, type: pagination_type
          param_definition.param :meta, optional: true, type: :object
        end

        private

        attr_reader :actions,
                    :schema_class,
                    :registrar

        def query_params(param_definition)
          filter_type = build_filter_type
          sort_type = build_sort_type

          if filter_type
            param_definition.param :filter, optional: true, type: :union do
              variant type: filter_type
              variant of: filter_type, type: :array
            end
          end

          if sort_type
            param_definition.param :sort, optional: true, type: :union do
              variant type: sort_type
              variant of: sort_type, type: :array
            end
          end

          page_type = build_page_type
          param_definition.param :page, optional: true, type: page_type

          return unless schema_class.association_definitions.any?

          include_type = build_include_type
          param_definition.param :include, optional: true, type: include_type if include_type
        end

        def writable_request(param_definition, context_symbol)
          root_key = schema_class.root_key.singular.to_sym
          builder = self

          if sti_base_schema?
            payload_type_name = sti_request_union(context_symbol)
          else
            payload_type_name = :"#{context_symbol}_payload"

            unless registrar.resolve_type(payload_type_name)
              registrar.type(payload_type_name, schema_class: schema_class) do
                builder.send(:writable_params, self, context_symbol, nested: false)
              end
            end
          end

          param_definition.param root_key, type: payload_type_name
        end

        def writable_params(param_definition, context_symbol, nested: false, target_schema: nil)
          target_schema_class = target_schema || schema_class
          target_schema_class.attribute_definitions.each do |name, attribute_definition|
            next unless attribute_definition.writable_for?(context_symbol)

            param_options = {
              type: map_type(attribute_definition.type),
              optional: attribute_definition.optional?,
              nullable: attribute_definition.nullable?,
              description: attribute_definition.description,
              example: attribute_definition.example,
              format: attribute_definition.format,
              deprecated: attribute_definition.deprecated,
              attribute_definition: attribute_definition,
            }

            param_options[:min] = attribute_definition.min if attribute_definition.min
            param_options[:max] = attribute_definition.max if attribute_definition.max
            param_options[:of] = attribute_definition.of if attribute_definition.of

            param_options[:enum] = name if attribute_definition.enum

            if attribute_definition.inline_shape
              param_definition.param name, **param_options, &attribute_definition.inline_shape
            else
              param_definition.param name, **param_options
            end
          end

          target_schema_class.association_definitions.each do |name, association_definition|
            next unless association_definition.writable_for?(context_symbol)

            association_resource = resolve_association_resource(association_definition)
            association_payload_type = nil

            association_contract = nil
            if association_resource&.schema_class
              import_alias = import_association_contract(association_resource.schema_class, Set.new)

              if import_alias
                association_payload_type = :"#{import_alias}_nested_payload"

                association_contract = registrar.find_contract_for_schema(association_resource.schema_class)
              end
            end

            param_options = {
              optional: true,
              nullable: association_definition.nullable?,
              as: "#{name}_attributes".to_sym,
              description: association_definition.description,
              example: association_definition.example,
              deprecated: association_definition.deprecated,
              association_definition: association_definition,
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

            param_definition.param name, **param_options
          end
        end

        def build_enums
          schema_class.attribute_definitions.each do |name, attribute_definition|
            next unless attribute_definition.enum&.any?

            registrar.enum(name, values: attribute_definition.enum)
          end
        end

        def build_actions
          actions.each_value do |action|
            build_action_definition(action)
          end
        end

        def build_action_definition(action)
          action_definition = registrar.define_action(action.name)

          build_request_for_action(action_definition, action) unless action_definition.resets_request?
          build_response_for_action(action_definition, action) unless action_definition.resets_response?
        end

        def build_request_for_action(action_definition, action)
          builder = self

          case action.name
          when :index
            action_definition.request do
              query { builder.send(:query_params, self) }
            end
          when :show
            build_member_query_params(action_definition)
          when :create
            action_definition.request do
              body { builder.send(:writable_request, self, :create) }
            end
            build_member_query_params(action_definition)
          when :update
            action_definition.request do
              body { builder.send(:writable_request, self, :update) }
            end
            build_member_query_params(action_definition)
          when :destroy
            build_member_query_params(action_definition)
          else
            build_member_query_params(action_definition) if action.member?
          end
        end

        def build_response_for_action(action_definition, action)
          result_wrapper = build_result_wrapper(action.name)

          case action.name
          when :index
            build_collection_response(action_definition, result_wrapper)
          when :show, :create, :update
            build_single_response(action_definition, result_wrapper)
          when :destroy
            action_definition.response { no_content! }
          else
            if action.method == :delete
              action_definition.response { no_content! }
            elsif action.collection?
              build_collection_response(action_definition, result_wrapper)
            elsif action.member?
              build_single_response(action_definition, result_wrapper)
            end
          end
        end

        def build_result_wrapper(action_name)
          success_type = registrar.scoped_name(:"#{action_name}_success_response_body")
          { error_type: :error_response_body, success_type: }
        end

        def build_single_response(action_definition, result_wrapper)
          builder = self
          action_definition.response do
            self.result_wrapper = result_wrapper
            body { builder.single_response(self) }
          end
        end

        def build_collection_response(action_definition, result_wrapper)
          builder = self
          action_definition.response do
            self.result_wrapper = result_wrapper
            body { builder.collection_response(self) }
          end
        end

        def build_member_query_params(action_definition)
          builder = self

          action_definition.request do
            query do
              if builder.send(:schema_class).association_definitions.any?
                include_type = builder.send(:build_include_type)
                param :include, optional: true, type: include_type if include_type
              end
            end
          end
        end

        def sti_request_union(context_symbol)
          union_type_name = :"#{context_symbol}_payload"
          discriminator_name = schema_class.discriminator_name
          discriminator_column = schema_class.discriminator_column
          builder = self
          sti_mapping = schema_class.needs_discriminator_transform? ? schema_class.discriminator_sti_mapping : nil

          build_sti_union(union_type_name: union_type_name) do |variant_schema, tag, _visited|
            variant_schema_name = variant_schema.name.demodulize.delete_suffix('Schema').underscore
            variant_type_name = :"#{variant_schema_name}_#{context_symbol}_payload"

            unless registrar.api_registrar.resolve_type(variant_type_name)
              registrar.api_registrar.type(variant_type_name) do
                # Rename discriminator from API name to DB column if different
                as_column = discriminator_name != discriminator_column ? discriminator_column : nil
                param discriminator_name, as: as_column, sti_mapping: sti_mapping, type: :literal, value: tag.to_s

                builder.send(:writable_params, self, context_symbol, nested: false, target_schema: variant_schema)
              end
            end

            variant_type_name
          end
        end

        def resource_type_name_for_response
          if sti_base_schema?
            build_sti_response_union_type
          else
            root_key = schema_class.root_key.singular.to_sym
            resource_type_name = registrar.scoped_name(nil)

            register_resource_type(root_key) unless registrar.resolve_type(resource_type_name)

            resource_type_name
          end
        end

        def register_resource_type(type_name)
          association_type_map = {}
          schema_class.association_definitions.each do |name, association_definition|
            association_type_map[name] = build_association_type(association_definition)
          end

          build_enums

          schema_class_local = schema_class
          builder = self
          registrar.type(type_name, schema_class: schema_class_local) do
            schema_class_local.attribute_definitions.each do |name, attribute_definition|
              enum_option = attribute_definition.enum ? { enum: name } : {}
              of_option = attribute_definition.of ? { of: attribute_definition.of } : {}

              param_options = {
                type: builder.send(:map_type, attribute_definition.type),
                nullable: attribute_definition.nullable?,
                description: attribute_definition.description,
                example: attribute_definition.example,
                format: attribute_definition.format,
                deprecated: attribute_definition.deprecated,
                attribute_definition: attribute_definition,
                **enum_option,
                **of_option,
              }

              if attribute_definition.inline_shape
                param name, **param_options, &attribute_definition.inline_shape
              else
                param name, **param_options
              end
            end

            schema_class_local.association_definitions.each do |name, association_definition|
              association_type = association_type_map[name]

              base_options = {
                optional: !association_definition.always_included?,
                nullable: association_definition.nullable?,
                description: association_definition.description,
                example: association_definition.example,
                deprecated: association_definition.deprecated,
                association_definition: association_definition,
              }

              if association_definition.singular?
                param name, type: association_type || :object, **base_options
              elsif association_definition.collection?
                if association_type
                  param name, type: :array, of: association_type, **base_options
                else
                  param name, type: :array, **base_options
                end
              end
            end
          end
        end

        def build_filter_type(depth: 0, visited: Set.new)
          return nil if visited.include?(schema_class)
          return nil if depth >= MAX_RECURSION_DEPTH

          visited = visited.dup.add(schema_class)

          return nil unless has_filterable_content?(visited)

          type_name = type_name(:filter, depth)

          existing_type = registrar.resolve_type(type_name)
          return type_name if existing_type

          builder = self
          schema_class_local = schema_class

          schema_class_local.attribute_definitions.each do |name, attribute_definition|
            next unless attribute_definition.filterable?
            next unless attribute_definition.enum

            register_enum_filter(name)
          end

          type_options = { schema_class: schema_class_local }
          type_options = {} unless depth.zero?

          registrar.type(type_name, **type_options) do
            param :_and, of: type_name, optional: true, type: :array
            param :_or, of: type_name, optional: true, type: :array
            param :_not, optional: true, type: type_name

            schema_class_local.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.filterable?
              next if attribute_definition.type == :unknown

              filter_type = builder.send(:filter_type_for, attribute_definition)

              if attribute_definition.enum
                param name, attribute_definition: attribute_definition, optional: true, type: filter_type
              else
                param name, attribute_definition: attribute_definition, optional: true, type: :union do
                  variant type: builder.send(:map_type, attribute_definition.type)
                  variant type: filter_type
                end
              end
            end

            schema_class_local.association_definitions.each do |name, association_definition|
              next unless association_definition.filterable?

              association_resource = builder.send(:resolve_association_resource, association_definition)
              next unless association_resource&.schema_class
              next if visited.include?(association_resource.schema_class)

              import_alias = builder.send(:import_association_contract, association_resource.schema_class, visited)

              association_filter_type = if import_alias
                                          :"#{import_alias}_filter"
                                        else
                                          builder.send(
                                            :build_filter_type_for_schema,
                                            association_resource.schema_class,
                                            visited: visited,
                                            depth: depth + 1,
                                          )
                                        end

              param name, association_definition: association_definition, optional: true, type: association_filter_type if association_filter_type
            end
          end

          type_name
        end

        def build_filter_type_for_schema(association_schema, depth:, visited:)
          self.class.for_schema(registrar, association_schema)
              .send(:build_filter_type, depth:, visited:)
        end

        def build_sort_type(depth: 0, visited: Set.new)
          return nil if visited.include?(schema_class)
          return nil if depth >= MAX_RECURSION_DEPTH

          visited = visited.dup.add(schema_class)

          return nil unless has_sortable_content?(visited)

          type_name = type_name(:sort, depth)

          existing_type = registrar.resolve_type(type_name)
          return type_name if existing_type

          builder = self
          schema_class_local = schema_class

          type_options = { schema_class: schema_class_local }
          type_options = {} unless depth.zero?

          registrar.type(type_name, **type_options) do
            schema_class_local.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.sortable?

              param name, attribute_definition: attribute_definition, optional: true, type: :sort_direction
            end

            schema_class_local.association_definitions.each do |name, association_definition|
              next unless association_definition.sortable?

              association_resource = builder.send(:resolve_association_resource, association_definition)
              next unless association_resource&.schema_class
              next if visited.include?(association_resource.schema_class)

              import_alias = builder.send(:import_association_contract, association_resource.schema_class, visited)

              association_sort_type = if import_alias
                                        :"#{import_alias}_sort"
                                      else
                                        builder.send(
                                          :build_sort_type_for_schema,
                                          association_resource.schema_class,
                                          visited: visited,
                                          depth: depth + 1,
                                        )
                                      end

              param name, association_definition: association_definition, optional: true, type: association_sort_type if association_sort_type
            end
          end

          type_name
        end

        def build_sort_type_for_schema(association_schema, depth:, visited:)
          self.class.for_schema(registrar, association_schema)
              .send(:build_sort_type, depth:, visited:)
        end

        def build_page_type
          strategy = schema_class.resolve_option(:pagination, :strategy)
          max_size = schema_class.resolve_option(:pagination, :max_size)

          type_name = type_name(:page, 1)

          existing_type = registrar.resolve_type(type_name)
          return type_name if existing_type

          if strategy == :cursor
            registrar.api_registrar.type(type_name, scope: nil) do
              param :after, optional: true, type: :string
              param :before, optional: true, type: :string
              param :size, max: max_size, min: 1, optional: true, type: :integer
            end
          else
            registrar.api_registrar.type(type_name, scope: nil) do
              param :number, min: 1, optional: true, type: :integer
              param :size, max: max_size, min: 1, optional: true, type: :integer
            end
          end

          type_name
        end

        def build_pagination_type
          strategy = schema_class.resolve_option(:pagination, :strategy)
          strategy == :offset ? :offset_pagination : :cursor_pagination
        end

        def build_include_type(depth: 0, visited: Set.new)
          return nil unless schema_class.association_definitions.any?
          return nil unless has_includable_params?(depth:, visited:)

          type_name = type_name(:include, depth)

          existing_type = registrar.resolve_type(type_name)
          return type_name if existing_type
          return type_name if depth >= MAX_RECURSION_DEPTH

          visited = visited.dup.add(schema_class)

          builder = self
          schema_class_local = schema_class
          registrar_local = registrar

          registrar.type(type_name) do
            schema_class_local.association_definitions.each do |name, association_definition|
              if association_definition.polymorphic?
                param name, optional: true, type: :boolean unless association_definition.always_included?
                next
              end

              association_resource = builder.send(:resolve_association_resource, association_definition)
              next unless association_resource&.schema_class

              if visited.include?(association_resource.schema_class)
                param name, optional: true, type: :boolean unless association_definition.always_included?
              else
                import_alias = builder.send(:import_association_contract, association_resource.schema_class, visited)

                association_include_type = if import_alias
                                             imported_type = :"#{import_alias}_include"
                                             registrar_local.resolve_type(imported_type) ? imported_type : nil
                                           else
                                             builder.send(
                                               :build_include_type_for_schema,
                                               association_resource.schema_class,
                                               visited: visited,
                                               depth: depth + 1,
                                             )
                                           end

                if association_include_type.nil?
                  param name, optional: true, type: :boolean unless association_definition.always_included?
                elsif association_definition.always_included?
                  param name, optional: true, type: association_include_type
                else
                  param name, optional: true, type: :union do
                    variant type: :boolean
                    variant type: association_include_type
                  end
                end
              end
            end
          end

          type_name
        end

        def has_includable_params?(depth:, visited:)
          return false if depth >= MAX_RECURSION_DEPTH

          new_visited = visited.dup.add(schema_class)

          schema_class.association_definitions.any? do |_name, association_definition|
            if association_definition.polymorphic?
              !association_definition.always_included?
            else
              association_resource = resolve_association_resource(association_definition)
              next false unless association_resource&.schema_class

              if new_visited.include?(association_resource.schema_class)
                !association_definition.always_included?
              elsif association_definition.always_included?
                nested_builder = self.class.for_schema(registrar, association_resource.schema_class)
                nested_builder.send(:has_includable_params?, depth: depth + 1, visited: new_visited)
              else
                true
              end
            end
          end
        end

        def build_include_type_for_schema(association_schema, depth:, visited:)
          self.class.for_schema(registrar, association_schema)
              .send(:build_include_type, depth:, visited:)
        end

        def build_nested_payload_union
          return unless schema_class.attribute_definitions.any? { |_, ad| ad.writable? } ||
                        schema_class.association_definitions.any? { |_, ad| ad.writable? }

          create_type_name = :nested_create_payload
          builder = self
          schema = schema_class

          unless registrar.resolve_type(create_type_name)
            registrar.type(create_type_name) do
              param :_type, type: :literal, value: 'create'
              builder.send(:writable_params, self, :create, nested: true)
              param :_destroy, optional: true, type: :boolean if schema.association_definitions.any? { |_, ad| ad.writable? && ad.allow_destroy }
            end
          end

          update_type_name = :nested_update_payload
          unless registrar.resolve_type(update_type_name)
            registrar.type(update_type_name) do
              param :_type, type: :literal, value: 'update'
              builder.send(:writable_params, self, :update, nested: true)
              param :_destroy, optional: true, type: :boolean if schema.association_definitions.any? { |_, ad| ad.writable? && ad.allow_destroy }
            end
          end

          nested_payload_type_name = :nested_payload
          return if registrar.resolve_type(nested_payload_type_name)

          create_qualified_name = registrar.scoped_name(create_type_name)
          update_qualified_name = registrar.scoped_name(update_type_name)

          registrar.union(nested_payload_type_name, discriminator: :_type) do
            variant tag: 'create', type: create_qualified_name
            variant tag: 'update', type: update_qualified_name
          end
        end

        def build_response_type(visited: Set.new)
          return if visited.include?(schema_class)

          visited = visited.dup.add(schema_class)

          return if sti_base_schema?

          root_key = schema_class.root_key.singular.to_sym
          resource_type_name = registrar.scoped_name(nil)

          return if registrar.resolve_type(resource_type_name)

          build_enums

          builder = self
          schema_class_local = schema_class

          registrar.type(root_key, schema_class: schema_class_local) do
            if schema_class_local.respond_to?(:sti_variant?) && schema_class_local.sti_variant?
              parent_schema = schema_class_local.superclass
              discriminator_name = parent_schema.discriminator_name
              variant_tag = schema_class_local.variant_tag.to_s

              param discriminator_name, type: :literal, value: variant_tag
            end

            association_type_map = {}
            schema_class_local.association_definitions.each do |name, association_definition|
              result = builder.send(:build_association_type, association_definition, visited: visited)
              association_type_map[name] = result
            end

            schema_class_local.attribute_definitions.each do |name, attribute_definition|
              enum_option = attribute_definition.enum ? { enum: name } : {}
              param name,
                    type: builder.send(:map_type, attribute_definition.type),
                    nullable: attribute_definition.nullable?,
                    description: attribute_definition.description,
                    example: attribute_definition.example,
                    format: attribute_definition.format,
                    deprecated: attribute_definition.deprecated,
                    attribute_definition: attribute_definition,
                    **enum_option
            end

            schema_class_local.association_definitions.each do |name, association_definition|
              association_type = association_type_map[name]
              is_optional = !association_definition.always_included?

              if association_type
                if association_definition.singular?
                  param name,
                        type: association_type,
                        optional: is_optional,
                        nullable: association_definition.nullable?,
                        association_definition: association_definition
                elsif association_definition.collection?
                  param name,
                        type: :array,
                        of: association_type,
                        optional: is_optional,
                        nullable: association_definition.nullable?,
                        association_definition: association_definition
                end
              elsif association_definition.singular?
                param name,
                      type: :object,
                      optional: is_optional,
                      nullable: association_definition.nullable?,
                      association_definition: association_definition
              elsif association_definition.collection?
                param name,
                      type: :array,
                      of: :object,
                      optional: is_optional,
                      nullable: association_definition.nullable?,
                      association_definition: association_definition
              end
            end
          end
        end

        def build_association_type(association_definition, visited: Set.new)
          return build_polymorphic_association_type(association_definition, visited: visited) if association_definition.polymorphic?

          association_resource = resolve_association_resource(association_definition)
          return nil unless association_resource

          return build_sti_association_type(association_definition, association_resource.schema_class, visited: visited) if association_resource.sti?

          return nil if visited.include?(association_resource.schema_class)

          import_alias = import_association_contract(association_resource.schema_class, visited)
          return import_alias if import_alias

          nil
        end

        def build_polymorphic_association_type(association_definition, visited: Set.new)
          polymorphic = association_definition.polymorphic
          return nil unless polymorphic&.any?

          union_type_name = association_definition.name

          existing_type = registrar.resolve_type(union_type_name)
          return union_type_name if existing_type

          builder = self
          discriminator = association_definition.discriminator
          association_def_local = association_definition

          registrar.union(union_type_name, discriminator:) do
            association_def_local.polymorphic.each_key do |tag|
              schema_class = association_def_local.resolve_polymorphic_schema(tag)
              next unless schema_class

              import_alias = builder.send(:import_association_contract, schema_class, visited)
              next unless import_alias

              variant tag: tag.to_s, type: import_alias
            end
          end

          union_type_name
        end

        def build_sti_union(union_type_name:, visited: Set.new)
          variants = schema_class.variants
          return nil unless variants&.any?

          discriminator_name = schema_class.discriminator_name

          variant_types = variants.filter_map do |tag, variant_data|
            variant_schema = variant_data[:schema]
            variant_type = yield(variant_schema, tag, visited)
            { tag: tag.to_s, type: variant_type } if variant_type
          end

          registrar.union(union_type_name, discriminator: discriminator_name) do
            variant_types.each do |v|
              variant tag: v[:tag], type: v[:type]
            end
          end

          union_type_name
        end

        def build_sti_association_type(association_definition, schema_class_arg, visited: Set.new)
          import_alias = import_association_contract(schema_class_arg, visited)
          return nil unless import_alias

          import_alias
        end

        def build_sti_response_union_type(visited: Set.new)
          union_type_name = schema_class.root_key.singular.to_sym
          discriminator_name = schema_class.discriminator_name
          builder = self

          build_sti_union(union_type_name: union_type_name, visited: visited) do |variant_schema, tag, _visit_set|
            variant_type_name = variant_schema.root_key.singular.to_sym

            unless registrar.api_registrar.resolve_type(variant_type_name)
              registrar.api_registrar.type(variant_type_name, schema_class: variant_schema) do
                param discriminator_name, type: :literal, value: tag.to_s

                variant_schema.attribute_definitions.each do |name, attribute_definition|
                  enum_option = attribute_definition.enum ? { enum: name } : {}
                  param name,
                        type: builder.send(:map_type, attribute_definition.type),
                        nullable: attribute_definition.nullable?,
                        description: attribute_definition.description,
                        example: attribute_definition.example,
                        format: attribute_definition.format,
                        deprecated: attribute_definition.deprecated,
                        attribute_definition: attribute_definition,
                        **enum_option
                end
              end
            end

            variant_type_name
          end
        end

        def determine_filter_type(attribute_type, nullable: false)
          base_type = case attribute_type
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
          scoped_name = registrar.scoped_name(attribute_definition.name)
          :"#{scoped_name}_filter"
        end

        def register_enum_filter(enum_name)
          scoped_name = registrar.scoped_name(enum_name)
          filter_name = :"#{scoped_name}_filter"

          return if registrar.api_registrar.resolve_type(filter_name)

          registrar.api_registrar.union(filter_name) do
            variant type: scoped_name
            variant partial: true, type: :object do
              param :eq, optional: true, type: scoped_name
              param :in, of: scoped_name, optional: true, type: :array
            end
          end
        end

        def sti_base_schema?
          return false unless schema_class.respond_to?(:sti_base?) && schema_class.sti_base?

          schema_class.respond_to?(:variants) && schema_class.variants&.any?
        end

        def resolve_association_resource(association_definition)
          return AssociationResource.polymorphic if association_definition.polymorphic?

          resolved_schema = resolve_schema_from_definition(association_definition)
          return nil unless resolved_schema

          sti = resolved_schema.respond_to?(:sti_base?) && resolved_schema.sti_base?
          AssociationResource.for(resolved_schema, sti:)
        end

        def resolve_schema_from_definition(association_definition)
          return association_definition.schema_class if association_definition.schema_class

          model_class = association_definition.model_class
          return nil unless model_class

          reflection = model_class.reflect_on_association(association_definition.name)
          return nil unless reflection

          infer_association_schema(reflection)
        end

        def infer_association_schema(reflection)
          return nil if reflection.polymorphic?

          namespace = schema_class.name.deconstantize
          "#{namespace}::#{reflection.klass.name}Schema".safe_constantize
        end

        def import_association_contract(association_schema, visited)
          return nil if visited.include?(association_schema)

          association_contract = registrar.find_contract_for_schema(association_schema)

          unless association_contract
            contract_name = association_schema.name.sub(/Schema$/, 'Contract')
            association_contract = begin
              contract_name.constantize
            rescue NameError
              nil
            end
          end

          return nil unless association_contract

          alias_name = association_schema.root_key.singular.to_sym

          registrar.import(association_contract, as: alias_name) unless registrar.imports.key?(alias_name)

          if association_contract.schema?
            api_class = association_contract.api_class
            api_class&.ensure_contract_built!(association_contract)

            association_registrar = ContractRegistrar.new(association_contract)
            sub_builder = self.class.for_schema(association_registrar, association_schema)

            sub_builder.send(:build_filter_type, depth: 0, visited: Set.new)
            sub_builder.send(:build_sort_type, depth: 0, visited: Set.new)
            sub_builder.send(:build_include_type, depth: 0, visited: Set.new)
            sub_builder.send(:build_nested_payload_union)
            sub_builder.send(:build_response_type, visited: Set.new)
          end

          alias_name
        end

        def has_filterable_content?(visited)
          has_filterable_attributes = schema_class.attribute_definitions.any? do |_, ad|
            ad.filterable? && ad.type != :unknown
          end

          return true if has_filterable_attributes

          schema_class.association_definitions.any? do |_, ad|
            next false unless ad.filterable?

            association_resource = resolve_association_resource(ad)
            association_resource&.schema_class && visited.exclude?(association_resource.schema_class)
          end
        end

        def has_sortable_content?(visited)
          has_sortable_attributes = schema_class.attribute_definitions.any? do |_, ad|
            ad.sortable?
          end

          return true if has_sortable_attributes

          schema_class.association_definitions.any? do |_, ad|
            next false unless ad.sortable?

            association_resource = resolve_association_resource(ad)
            association_resource&.schema_class && visited.exclude?(association_resource.schema_class)
          end
        end

        def type_name(base_name, depth)
          return base_name if depth.zero?

          schema_name = schema_class.name.demodulize.delete_suffix('Schema').underscore
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
