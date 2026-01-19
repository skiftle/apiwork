# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Envelope
        class Resource
          class TypeBuilder
            attr_reader :actions,
                        :registrar,
                        :schema_class

            class << self
              def build(registrar, schema_class, actions)
                new(registrar, schema_class, actions).build
              end
            end

            def initialize(registrar, schema_class, actions)
              @registrar = registrar
              @schema_class = schema_class
              @actions = actions
            end

            def build
              build_enums
              build_actions
            end

            def single_response(response)
              response.reference schema_class.root_key.singular.to_sym, to: resource_type_name_for_response
              response.object :meta, optional: true
            end

            def collection_response(response)
              type_name = resource_type_name_for_response

              response.array schema_class.root_key.plural.to_sym do
                reference type_name
              end
              response.reference :pagination, to: pagination_response_type
              response.object :meta, optional: true
            end

            def writable_request(request, action_name)
              payload_type_name = :"#{action_name}_payload"

              return unless registrar.type?(payload_type_name)

              request.reference schema_class.root_key.singular.to_sym, to: payload_type_name
            end

            private

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
              when :create
                contract_action.request do
                  body { builder.writable_request(self, :create) }
                end
              when :update
                contract_action.request do
                  body { builder.writable_request(self, :update) }
                end
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

              { error_type: :error_response_body, success_type: registrar.scoped_type_name(success_type_name) }
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

            def resource_type_name_for_response
              if sti_base_schema?
                build_sti_response_union_type
              else
                register_resource_type(schema_class.root_key.singular.to_sym) unless registrar.type?(registrar.scoped_type_name(nil))

                registrar.scoped_type_name(nil)
              end
            end

            def register_resource_type(type_name)
              association_type_map = {}
              schema_class.associations.each do |name, association|
                association_type_map[name] = build_association_type(association)
              end

              build_enums

              local_schema_class = schema_class
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
                    type: TypeMapper.map(attribute.type),
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

                  param name, **param_options
                end

                local_schema_class.associations.each do |name, association|
                  association_type = association_type_map[name]

                  base_options = {
                    deprecated: association.deprecated,
                    description: association.description,
                    example: association.example,
                    nullable: association.nullable?,
                    optional: association.include != :always,
                  }

                  if association.singular?
                    param name, type: association_type || :object, **base_options
                  elsif association.collection?
                    if association_type
                      param name, type: :array, **base_options do
                        of association_type
                      end
                    else
                      param name, type: :array, **base_options
                    end
                  end
                end
              end
            end

            def pagination_response_type
              strategy = schema_class.adapter_config.pagination.strategy
              strategy == :offset ? :offset_pagination : :cursor_pagination
            end

            def sti_base_schema?
              return false unless schema_class.discriminated?

              schema_class.union&.variants&.any?
            end

            def build_sti_union(union_type_name:, visited: Set.new)
              schema_union = schema_class.union
              return nil unless schema_union&.variants&.any?

              discriminator_name = schema_union.discriminator

              variant_types = schema_union.variants.filter_map do |tag, variant|
                variant_schema_class = variant.schema_class
                variant_type = yield(variant_schema_class, tag, visited)
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

            def build_sti_response_union_type(visited: Set.new)
              union_type_name = schema_class.root_key.singular.to_sym
              discriminator_name = schema_class.union.discriminator

              build_sti_union(union_type_name:, visited: visited) do |variant_schema_class, tag, _visit_set|
                variant_type_name = variant_schema_class.root_key.singular.to_sym

                unless registrar.api_registrar.type?(variant_type_name)
                  registrar.api_registrar.object(variant_type_name, schema_class: variant_schema_class) do
                    literal discriminator_name, value: tag.to_s

                    variant_schema_class.attributes.each do |name, attribute|
                      enum_option = attribute.enum ? { enum: name } : {}
                      param name,
                            deprecated: attribute.deprecated,
                            description: attribute.description,
                            example: attribute.example,
                            format: attribute.format,
                            nullable: attribute.nullable?,
                            type: TypeMapper.map(attribute.type),
                            **enum_option
                    end
                  end
                end

                variant_type_name
              end
            end

            def build_association_type(association, visited: Set.new)
              return build_polymorphic_association_type(association, visited:) if association.polymorphic?

              association_resource = resolve_association_resource(association)
              return nil unless association_resource

              return build_sti_association_type(association, association_resource.schema_class, visited:) if association_resource.sti?

              return nil if visited.include?(association_resource.schema_class)

              alias_name = registrar.ensure_association_types(association)
              return alias_name if alias_name

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
                  association_schema_class = association_local.resolve_polymorphic_schema(tag)
                  next unless association_schema_class

                  alias_name = builder.import_association_contract(association_schema_class, visited)
                  next unless alias_name

                  variant tag: tag.to_s do
                    reference alias_name
                  end
                end
              end

              union_type_name
            end

            def build_sti_association_type(association, association_schema_class, visited: Set.new)
              alias_name = import_association_contract(association_schema_class, visited)
              return nil unless alias_name

              alias_name
            end

            def resolve_association_resource(association)
              return AssociationResource.polymorphic if association.polymorphic?

              resolved_schema = resolve_schema_from_association(association)
              return nil unless resolved_schema

              sti = resolved_schema.discriminated?
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
              "#{namespace}::#{reflection.klass.name.demodulize}Schema".safe_constantize
            end

            def import_association_contract(association_schema, visited)
              return nil if visited.include?(association_schema)

              association_contract_class = registrar.find_contract_for_schema(association_schema)

              unless association_contract_class
                contract_name = association_schema.name.sub(/Schema$/, 'Contract')
                association_contract_class = begin
                  contract_name.constantize
                rescue NameError
                  nil
                end
              end

              return nil unless association_contract_class

              alias_name = association_schema.root_key.singular.to_sym

              registrar.import(association_contract_class, as: alias_name) unless registrar.imports.key?(alias_name)

              association_contract_class.api_class.ensure_contract_built!(association_contract_class) if association_contract_class.schema?

              alias_name
            end
          end
        end
      end
    end
  end
end
