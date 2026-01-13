# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class ContractBuilder
        MAX_RECURSION_DEPTH = 3

        def self.build(registrar, schema_class, actions)
          new(registrar, schema_class, actions:, build: true)
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

        def single_response(response)
          root_key = schema_class.root_key.singular.to_sym
          resource_type_name = resource_type_name_for_response

          response.reference root_key, to: resource_type_name
          response.object :meta, optional: true
        end

        def collection_response(response)
          root_key_plural = schema_class.root_key.plural.to_sym
          resource_type_name = resource_type_name_for_response
          pagination_type = build_pagination_type

          response.array root_key_plural do
            reference resource_type_name
          end
          response.reference :pagination, to: pagination_type
          response.object :meta, optional: true
        end

        attr_reader :actions,
                    :registrar,
                    :schema_class

        def query_params(request)
          filter_type = build_filter_type
          sort_type = build_sort_type

          if filter_type
            request.union :filter, optional: true do
              variant { reference filter_type }
              variant { array { reference filter_type } }
            end
          end

          if sort_type
            request.union :sort, optional: true do
              variant { reference sort_type }
              variant { array { reference sort_type } }
            end
          end

          request.reference :page, optional: true, to: build_page_type

          return unless schema_class.associations.any?

          include_type = build_include_type
          request.reference :include, optional: true, to: include_type if include_type
        end

        def writable_request(request, action_name)
          root_key = schema_class.root_key.singular.to_sym
          builder = self

          if sti_base_schema?
            payload_type_name = sti_request_union(action_name)
          else
            payload_type_name = :"#{action_name}_payload"

            unless registrar.type?(payload_type_name)
              registrar.object(payload_type_name, schema_class: schema_class) do
                builder.writable_params(self, action_name, nested: false)
              end
            end
          end

          request.reference root_key, to: payload_type_name
        end

        def writable_params(request, action_name, nested: false, target_schema: nil)
          target_schema_class = target_schema || schema_class
          target_schema_class.attributes.each do |name, attribute|
            next unless attribute.writable_for?(action_name)

            param_options = {
              deprecated: attribute.deprecated,
              description: attribute.description,
              example: attribute.example,
              format: attribute.format,
              nullable: attribute.nullable?,
              optional: action_name == :update || attribute.optional?,
              type: map_type(attribute.type),
            }

            param_options[:min] = attribute.min if attribute.min
            param_options[:max] = attribute.max if attribute.max
            param_options[:of] = attribute.of if attribute.of

            param_options[:enum] = name if attribute.enum

            if attribute.element
              element = attribute.element

              if element.type == :array
                param_options[:of] = { type: element.of_type }
                param_options[:shape] = element.shape
              else
                param_options[:shape] = element.shape
                param_options[:discriminator] = element.discriminator if element.discriminator
              end
            end

            param_definition.param name, param_options.delete(:type), **param_options
          end

          target_schema_class.associations.each do |name, association|
            next unless association.writable_for?(action_name)

            association_resource = resolve_association_resource(association)
            association_payload_type = nil

            association_contract = nil
            if association_resource&.schema_class
              import_alias = import_association_contract(association_resource.schema_class, Set.new)

              if import_alias
                association_payload_type = :"#{import_alias}_nested_payload"

                association_contract = registrar.find_contract_for_schema(association_resource.schema_class)

                if association_contract&.schema?
                  association_registrar = ContractRegistrar.new(association_contract)
                  sub_builder = self.class.for_schema(association_registrar, association_resource.schema_class)
                  sub_builder.build_nested_payload_union
                end
              end
            end

            param_options = {
              as: "#{name}_attributes".to_sym,
              deprecated: association.deprecated,
              description: association.description,
              example: association.example,
              nullable: association.nullable?,
              optional: true,
            }

            if association_payload_type
              if association.collection?
                param_options[:type] = :array
                param_options[:of] = association_payload_type
              else
                param_options[:type] = association_payload_type
              end
            else
              param_options[:type] = association.collection? ? :array : :object
            end

            param_definition.param name, param_options.delete(:type), **param_options
          end
        end

        def build_enums
          schema_class.attributes.each do |name, attribute|
            next unless attribute.enum&.any?

            registrar.enum(name, values: attribute.enum)
          end
        end

        def build_actions
          actions.each_value do |action|
            build_action(action)
          end
        end

        def build_action(action)
          contract_action = registrar.action(action.name)

          build_request_for_action(action, contract_action) unless contract_action.resets_request?
          build_response_for_action(action, contract_action) unless contract_action.resets_response?
        end

        def build_request_for_action(action, contract_action)
          builder = self

          case action.name
          when :index
            contract_action.request do
              query { builder.query_params(self) }
            end
          when :show
            build_member_query_params(contract_action)
          when :create
            contract_action.request do
              body { builder.writable_request(self, :create) }
            end
            build_member_query_params(contract_action)
          when :update
            contract_action.request do
              body { builder.writable_request(self, :update) }
            end
            build_member_query_params(contract_action)
          when :destroy
            build_member_query_params(contract_action)
          else
            build_member_query_params(contract_action) if action.member?
          end
        end

        def build_response_for_action(action, contract_action)
          case action.name
          when :index
            result_wrapper = build_result_wrapper(action.name, response_type: :collection)
            build_collection_response(contract_action, result_wrapper)
          when :show, :create, :update
            result_wrapper = build_result_wrapper(action.name, response_type: :single)
            build_single_response(contract_action, result_wrapper)
          when :destroy
            contract_action.response { no_content! }
          else
            if action.method == :delete
              contract_action.response { no_content! }
            elsif action.collection?
              result_wrapper = build_result_wrapper(action.name, response_type: :collection)
              build_collection_response(contract_action, result_wrapper)
            elsif action.member?
              result_wrapper = build_result_wrapper(action.name, response_type: :single)
              build_single_response(contract_action, result_wrapper)
            end
          end
        end

        def build_result_wrapper(action_name, response_type:)
          success_type_name = :"#{action_name}_success_response_body"
          full_name = registrar.scoped_type_name(success_type_name)

          unless registrar.type?(success_type_name)
            builder = self
            registrar.object(success_type_name) do
              if response_type == :collection
                builder.collection_response(self)
              else
                builder.single_response(self)
              end
            end
          end

          { error_type: :error_response_body, success_type: full_name }
        end

        def build_single_response(contract_action, result_wrapper)
          builder = self
          contract_action.response do
            self.result_wrapper = result_wrapper
            body { builder.single_response(self) }
          end
        end

        def build_collection_response(contract_action, result_wrapper)
          builder = self
          contract_action.response do
            self.result_wrapper = result_wrapper
            body { builder.collection_response(self) }
          end
        end

        def build_member_query_params(contract_action)
          builder = self

          contract_action.request do
            query do
              if builder.schema_class.associations.any?
                include_type = builder.build_include_type
                reference :include, optional: true, to: include_type if include_type
              end
            end
          end
        end

        def sti_request_union(action_name)
          union_type_name = :"#{action_name}_payload"
          discriminator_name = schema_class.discriminator_name
          discriminator_column = schema_class.discriminator_column
          builder = self
          needs_transform = schema_class.needs_discriminator_transform?
          local_schema_class = schema_class

          build_sti_union(union_type_name: union_type_name) do |variant_schema, tag, _visited|
            variant_schema_name = variant_schema.name.demodulize.delete_suffix('Schema').underscore
            variant_type_name = :"#{variant_schema_name}_#{action_name}_payload"

            unless registrar.api_registrar.type?(variant_type_name)
              registrar.api_registrar.object(variant_type_name) do
                as_column = discriminator_name != discriminator_column ? discriminator_column : nil
                discriminator_optional = action_name == :update
                variant = local_schema_class.variants[tag.to_sym]
                store_value = needs_transform && variant ? variant.type : nil

                literal discriminator_name, as: as_column, optional: discriminator_optional, store: store_value, value: tag.to_s

                builder.writable_params(self, action_name, nested: false, target_schema: variant_schema)
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
            resource_type_name = registrar.scoped_type_name(nil)

            register_resource_type(root_key) unless registrar.type?(resource_type_name)

            resource_type_name
          end
        end

        def register_resource_type(type_name)
          association_type_map = {}
          schema_class.associations.each do |name, association|
            association_type_map[name] = build_association_type(association)
          end

          build_enums

          local_schema_class = schema_class
          builder = self
          registrar.object(type_name, schema_class: local_schema_class) do
            local_schema_class.attributes.each do |name, attribute|
              enum_option = attribute.enum ? { enum: name } : {}
              of_option = attribute.of ? { of: attribute.of } : {}

              param_options = {
                deprecated: attribute.deprecated,
                description: attribute.description,
                example: attribute.example,
                format: attribute.format,
                nullable: attribute.nullable?,
                type: builder.map_type(attribute.type),
                **enum_option,
                **of_option,
              }

              if attribute.element
                element = attribute.element

                if element.type == :array
                  param_options[:of] = { type: element.of_type }
                  param_options[:shape] = element.shape
                else
                  param_options[:shape] = element.shape
                  param_options[:discriminator] = element.discriminator if element.discriminator
                end
              end

              param name, param_options.delete(:type), **param_options
            end

            local_schema_class.associations.each do |name, association|
              association_type = association_type_map[name]

              base_options = {
                deprecated: association.deprecated,
                description: association.description,
                example: association.example,
                nullable: association.nullable?,
                optional: !association.always_included?,
              }

              if association.singular?
                param name, association_type || :object, **base_options
              elsif association.collection?
                if association_type
                  param name, :array, **base_options do
                    of association_type
                  end
                else
                  param name, :array, **base_options
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

          existing_type = registrar.type?(type_name)
          return type_name if existing_type

          builder = self
          local_schema_class = schema_class

          local_schema_class.attributes.each do |name, attribute|
            next unless attribute.filterable?
            next unless attribute.enum

            register_enum_filter(name)
          end

          type_options = { schema_class: local_schema_class }
          type_options = {} unless depth.zero?

          registrar.object(type_name, **type_options) do
            array :_and, optional: true do
              reference type_name
            end
            array :_or, optional: true do
              reference type_name
            end
            reference :_not, optional: true, to: type_name

            local_schema_class.attributes.each do |name, attribute|
              next unless attribute.filterable?
              next if attribute.type == :unknown

              filter_type = builder.filter_type_for(attribute)

              if attribute.enum
                reference name, optional: true, to: filter_type
              else
                mapped_type = builder.map_type(attribute.type)
                if %i[object array union].include?(mapped_type)
                  reference name, optional: true, to: filter_type
                else
                  union name, optional: true do
                    variant { of(mapped_type) }
                    variant { reference filter_type }
                  end
                end
              end
            end

            local_schema_class.associations.each do |name, association|
              next unless association.filterable?

              association_resource = builder.resolve_association_resource(association)
              next unless association_resource&.schema_class
              next if visited.include?(association_resource.schema_class)

              import_alias = builder.import_association_contract(association_resource.schema_class, visited)

              association_filter_type = if import_alias
                                          :"#{import_alias}_filter"
                                        else
                                          builder.build_filter_type_for_schema(
                                            association_resource.schema_class,
                                            visited:,
                                            depth: depth + 1,
                                          )
                                        end

              reference name, optional: true, to: association_filter_type if association_filter_type
            end
          end

          type_name
        end

        def build_filter_type_for_schema(association_schema, depth:, visited:)
          self.class.for_schema(registrar, association_schema)
            .build_filter_type(depth:, visited:)
        end

        def build_sort_type(depth: 0, visited: Set.new)
          return nil if visited.include?(schema_class)
          return nil if depth >= MAX_RECURSION_DEPTH

          visited = visited.dup.add(schema_class)

          return nil unless has_sortable_content?(visited)

          type_name = type_name(:sort, depth)

          existing_type = registrar.type?(type_name)
          return type_name if existing_type

          builder = self
          local_schema_class = schema_class

          type_options = { schema_class: local_schema_class }
          type_options = {} unless depth.zero?

          registrar.object(type_name, **type_options) do
            local_schema_class.attributes.each do |name, attribute|
              next unless attribute.sortable?

              reference name, optional: true, to: :sort_direction
            end

            local_schema_class.associations.each do |name, association|
              next unless association.sortable?

              association_resource = builder.resolve_association_resource(association)
              next unless association_resource&.schema_class
              next if visited.include?(association_resource.schema_class)

              import_alias = builder.import_association_contract(association_resource.schema_class, visited)

              association_sort_type = if import_alias
                                        :"#{import_alias}_sort"
                                      else
                                        builder.build_sort_type_for_schema(
                                          association_resource.schema_class,
                                          visited:,
                                          depth: depth + 1,
                                        )
                                      end

              reference name, optional: true, to: association_sort_type if association_sort_type
            end
          end

          type_name
        end

        def build_sort_type_for_schema(association_schema, depth:, visited:)
          self.class.for_schema(registrar, association_schema)
            .build_sort_type(depth:, visited:)
        end

        def build_page_type
          strategy = schema_class.resolve_option(:pagination, :strategy)
          max_size = schema_class.resolve_option(:pagination, :max_size)

          type_name = type_name(:page, 1)

          existing_type = registrar.type?(type_name)
          return type_name if existing_type

          if strategy == :cursor
            registrar.api_registrar.object(type_name, scope: nil) do
              string :after, optional: true
              string :before, optional: true
              integer :size, max: max_size, min: 1, optional: true
            end
          else
            registrar.api_registrar.object(type_name, scope: nil) do
              integer :number, min: 1, optional: true
              integer :size, max: max_size, min: 1, optional: true
            end
          end

          type_name
        end

        def build_pagination_type
          strategy = schema_class.resolve_option(:pagination, :strategy)
          strategy == :offset ? :offset_pagination : :cursor_pagination
        end

        def build_include_type(depth: 0, visited: Set.new)
          return nil unless schema_class.associations.any?
          return nil unless has_includable_params?(depth:, visited:)

          type_name = type_name(:include, depth)

          existing_type = registrar.type?(type_name)
          return type_name if existing_type
          return type_name if depth >= MAX_RECURSION_DEPTH

          visited = visited.dup.add(schema_class)

          builder = self
          local_schema_class = schema_class
          registrar_local = registrar

          registrar.object(type_name) do
            local_schema_class.associations.each do |name, association|
              if association.polymorphic?
                boolean name, optional: true unless association.always_included?
                next
              end

              association_resource = builder.resolve_association_resource(association)
              next unless association_resource&.schema_class

              if visited.include?(association_resource.schema_class)
                boolean name, optional: true unless association.always_included?
              else
                import_alias = builder.import_association_contract(association_resource.schema_class, visited)

                association_include_type = if import_alias
                                             imported_type = :"#{import_alias}_include"
                                             registrar_local.type?(imported_type) ? imported_type : nil
                                           else
                                             builder.build_include_type_for_schema(
                                               association_resource.schema_class,
                                               visited:,
                                               depth: depth + 1,
                                             )
                                           end

                if association_include_type.nil?
                  boolean name, optional: true unless association.always_included?
                elsif association.always_included?
                  reference name, optional: true, to: association_include_type
                else
                  union name, optional: true do
                    variant { boolean }
                    variant { reference association_include_type }
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

          schema_class.associations.values.any? do |association|
            if association.polymorphic?
              !association.always_included?
            else
              association_resource = resolve_association_resource(association)
              next false unless association_resource&.schema_class

              if new_visited.include?(association_resource.schema_class)
                !association.always_included?
              elsif association.always_included?
                nested_builder = self.class.for_schema(registrar, association_resource.schema_class)
                nested_builder.has_includable_params?(depth: depth + 1, visited: new_visited)
              else
                true
              end
            end
          end
        end

        def build_include_type_for_schema(association_schema, depth:, visited:)
          self.class.for_schema(registrar, association_schema)
            .build_include_type(depth:, visited:)
        end

        def build_nested_payload_union
          return unless schema_class.attributes.values.any?(&:writable?) ||
                        schema_class.associations.values.any?(&:writable?)

          create_type_name = :nested_create_payload
          builder = self
          schema_class

          unless registrar.type?(create_type_name)
            registrar.object(create_type_name) do
              literal :_type, value: 'create'
              integer :id, optional: true
              builder.writable_params(self, :create, nested: true)
              boolean :_destroy, optional: true
            end
          end

          update_type_name = :nested_update_payload
          unless registrar.type?(update_type_name)
            registrar.object(update_type_name) do
              literal :_type, value: 'update'
              integer :id, optional: true
              builder.writable_params(self, :update, nested: true)
              boolean :_destroy, optional: true
            end
          end

          nested_payload_type_name = :nested_payload
          return if registrar.type?(nested_payload_type_name)

          create_qualified_name = registrar.scoped_type_name(create_type_name)
          update_qualified_name = registrar.scoped_type_name(update_type_name)

          registrar.union(nested_payload_type_name, discriminator: :_type) do
            variant tag: 'create' do
              reference create_qualified_name
            end
            variant tag: 'update' do
              reference update_qualified_name
            end
          end
        end

        def build_response_type(visited: Set.new)
          return if visited.include?(schema_class)

          visited = visited.dup.add(schema_class)

          return if sti_base_schema?

          root_key = schema_class.root_key.singular.to_sym
          resource_type_name = registrar.scoped_type_name(nil)

          return if registrar.type?(resource_type_name)

          build_enums

          builder = self
          local_schema_class = schema_class

          registrar.object(root_key, schema_class: local_schema_class) do
            if local_schema_class.respond_to?(:sti_variant?) && local_schema_class.sti_variant?
              parent_schema = local_schema_class.superclass
              discriminator_name = parent_schema.discriminator_name
              variant_tag = local_schema_class.variant_tag.to_s

              literal discriminator_name, value: variant_tag
            end

            association_type_map = {}
            local_schema_class.associations.each do |name, association|
              result = builder.build_association_type(association, visited:)
              association_type_map[name] = result
            end

            local_schema_class.attributes.each do |name, attribute|
              enum_option = attribute.enum ? { enum: name } : {}
              param name,
                    builder.map_type(attribute.type),
                    deprecated: attribute.deprecated,
                    description: attribute.description,
                    example: attribute.example,
                    format: attribute.format,
                    nullable: attribute.nullable?,
                    **enum_option
            end

            local_schema_class.associations.each do |name, association|
              association_type = association_type_map[name]
              is_optional = !association.always_included?

              if association_type
                if association.singular?
                  param name,
                        association_type,
                        nullable: association.nullable?,
                        optional: is_optional
                elsif association.collection?
                  param name,
                        :array,
                        nullable: association.nullable?,
                        of: association_type,
                        optional: is_optional
                end
              elsif association.singular?
                param name, :object, nullable: association.nullable?, optional: is_optional
              elsif association.collection?
                param name,
                      :array,
                      nullable: association.nullable?,
                      of: :object,
                      optional: is_optional
              end
            end
          end
        end

        def build_association_type(association, visited: Set.new)
          return build_polymorphic_association_type(association, visited:) if association.polymorphic?

          association_resource = resolve_association_resource(association)
          return nil unless association_resource

          return build_sti_association_type(association, association_resource.schema_class, visited:) if association_resource.sti?

          return nil if visited.include?(association_resource.schema_class)

          import_alias = import_association_contract(association_resource.schema_class, visited)
          return import_alias if import_alias

          nil
        end

        def build_polymorphic_association_type(association, visited: Set.new)
          polymorphic = association.polymorphic
          return nil unless polymorphic&.any?

          union_type_name = association.name

          existing_type = registrar.type?(union_type_name)
          return union_type_name if existing_type

          builder = self
          discriminator = association.discriminator
          association_local = association

          registrar.union(union_type_name, discriminator:) do
            association_local.polymorphic.each_key do |tag|
              schema_class = association_local.resolve_polymorphic_schema(tag)
              next unless schema_class

              import_alias = builder.import_association_contract(schema_class, visited)
              next unless import_alias

              variant tag: tag.to_s do
                reference import_alias
              end
            end
          end

          union_type_name
        end

        def build_sti_union(union_type_name:, visited: Set.new)
          variants = schema_class.variants
          return nil unless variants&.any?

          discriminator_name = schema_class.discriminator_name

          variant_types = variants.filter_map do |tag, variant_data|
            variant_schema = variant_data.schema_class
            variant_type = yield(variant_schema, tag, visited)
            { tag: tag.to_s, type: variant_type } if variant_type
          end

          registrar.union(union_type_name, discriminator: discriminator_name) do
            variant_types.each do |variant_type|
              variant tag: variant_type[:tag] do
                reference variant_type[:type]
              end
            end
          end

          union_type_name
        end

        def build_sti_association_type(association, schema_class_arg, visited: Set.new)
          import_alias = import_association_contract(schema_class_arg, visited)
          return nil unless import_alias

          import_alias
        end

        def build_sti_response_union_type(visited: Set.new)
          union_type_name = schema_class.root_key.singular.to_sym
          discriminator_name = schema_class.discriminator_name
          builder = self

          build_sti_union(union_type_name:, visited: visited) do |variant_schema, tag, _visit_set|
            variant_type_name = variant_schema.root_key.singular.to_sym

            unless registrar.api_registrar.type?(variant_type_name)
              registrar.api_registrar.object(variant_type_name, schema_class: variant_schema) do
                literal discriminator_name, value: tag.to_s

                variant_schema.attributes.each do |name, attribute|
                  enum_option = attribute.enum ? { enum: name } : {}
                  param name,
                        builder.map_type(attribute.type),
                        deprecated: attribute.deprecated,
                        description: attribute.description,
                        example: attribute.example,
                        format: attribute.format,
                        nullable: attribute.nullable?,
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
                      when :decimal
                        :decimal_filter
                      when :number
                        :number_filter
                      when :uuid
                        :uuid_filter
                      when :boolean
                        :boolean_filter
                      else
                        :string_filter
                      end

          nullable ? :"nullable_#{base_type}" : base_type
        end

        def filter_type_for(attribute)
          return enum_filter_type(attribute) if attribute.enum

          determine_filter_type(attribute.type, nullable: attribute.nullable?)
        end

        def enum_filter_type(attribute)
          scoped_name = registrar.scoped_type_name(attribute.name)
          :"#{scoped_name}_filter"
        end

        def register_enum_filter(enum_name)
          scoped_name = registrar.scoped_enum_name(enum_name)
          filter_name = :"#{scoped_name}_filter"

          return if registrar.api_registrar.type?(filter_name)

          registrar.api_registrar.union(filter_name) do
            variant { reference scoped_name }
            variant partial: true do
              object do
                reference :eq, to: scoped_name
                array :in do
                  reference scoped_name
                end
              end
            end
          end
        end

        def sti_base_schema?
          return false unless schema_class.respond_to?(:sti_base?) && schema_class.sti_base?

          schema_class.respond_to?(:variants) && schema_class.variants&.any?
        end

        def resolve_association_resource(association)
          return AssociationResource.polymorphic if association.polymorphic?

          resolved_schema = resolve_schema_from_association(association)
          return nil unless resolved_schema

          sti = resolved_schema.respond_to?(:sti_base?) && resolved_schema.sti_base?
          AssociationResource.for(resolved_schema, sti:)
        end

        def resolve_schema_from_association(association)
          return association.schema_class if association.schema_class

          model_class = association.model_class
          return nil unless model_class

          reflection = model_class.reflect_on_association(association.name)
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
            association_contract.api_class.ensure_contract_built!(association_contract)

            association_registrar = ContractRegistrar.new(association_contract)
            sub_builder = self.class.for_schema(association_registrar, association_schema)

            sub_builder.build_filter_type(depth: 0, visited: Set.new)
            sub_builder.build_sort_type(depth: 0, visited: Set.new)
            sub_builder.build_include_type(depth: 0, visited: Set.new)
            sub_builder.build_response_type(visited: Set.new)
          end

          alias_name
        end

        def has_filterable_content?(visited)
          has_filterable_attributes = schema_class.attributes.values.any? do |attribute|
            attribute.filterable? && attribute.type != :unknown
          end

          return true if has_filterable_attributes

          schema_class.associations.values.any? do |association|
            next false unless association.filterable?

            association_resource = resolve_association_resource(association)
            association_resource&.schema_class && visited.exclude?(association_resource.schema_class)
          end
        end

        def has_sortable_content?(visited)
          has_sortable_attributes = schema_class.attributes.values.any?(&:sortable?)

          return true if has_sortable_attributes

          schema_class.associations.values.any? do |association|
            next false unless association.sortable?

            association_resource = resolve_association_resource(association)
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
          when :decimal, :number then :decimal
          when :object then :object
          when :array then :array
          else :unknown
          end
        end
      end
    end
  end
end
