# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class ContractBuilder < Adapter::Capability::Contract::Base
            TYPE_NAME = :include
            MAX_RECURSION_DEPTH = 3

            def build
              return unless build_type(representation_class)

              scope.actions.each_key do |action_name|
                action(action_name) do |action|
                  action.request do |request|
                    request.query do |query|
                      query.reference?(TYPE_NAME)
                    end
                  end
                end
              end
            end

            private

            def build_type(representation_class, depth: 0, visited: Set.new)
              return nil unless representation_class.associations.any?
              return nil unless includable_params?(representation_class, depth:, visited:)

              type_name = type_name_for(representation_class, depth)
              return type_name if type?(type_name)
              return type_name if depth >= MAX_RECURSION_DEPTH

              visited = visited.dup.add(representation_class)

              association_params = compute_association_params(
                representation_class,
                depth:,
                visited:,
              )

              object(type_name) do |object|
                association_params.each do |param_data|
                  name = param_data[:name]
                  include_type = param_data[:include_type]

                  case param_data[:param_type]
                  when :boolean
                    object.boolean(name, optional: true) unless param_data[:include_mode] == :always
                  when :reference
                    object.reference(name, optional: true, to: include_type)
                  when :union
                    object.union(name, optional: true) do |union|
                      union.variant(&:boolean)
                      union.variant do |element|
                        element.reference(include_type)
                      end
                    end
                  end
                end
              end

              type_name
            end

            def compute_association_params(representation_class, depth:, visited:)
              representation_class.associations.filter_map do |name, association|
                compute_single_association_param(name, association, representation_class, depth:, visited:)
              end
            end

            def compute_single_association_param(name, association, representation_class, depth:, visited:)
              if association.polymorphic?
                return {
                  name:,
                  include_mode: association.include,
                  include_type: nil,
                  param_type: :boolean,
                }
              end

              nested_representation_class = resolve_association_representation_class(representation_class, association)
              return nil unless nested_representation_class

              if visited.include?(nested_representation_class)
                return {
                  name:,
                  include_mode: association.include,
                  include_type: nil,
                  param_type: :boolean,
                }
              end

              association_include_type = resolve_association_include_type(
                nested_representation_class,
                depth:,
                visited:,
              )

              if association_include_type.nil?
                {
                  name:,
                  include_mode: association.include,
                  include_type: nil,
                  param_type: :boolean,
                }
              elsif association.include == :always
                {
                  name:,
                  include_mode: association.include,
                  include_type: association_include_type,
                  param_type: :reference,
                }
              else
                {
                  name:,
                  include_mode: association.include,
                  include_type: association_include_type,
                  param_type: :union,
                }
              end
            end

            def resolve_association_include_type(representation_class, depth:, visited:)
              contract_class = contract_for(representation_class)
              return build_type(representation_class, visited:, depth: depth + 1) unless contract_class

              alias_name = representation_class.root_key.singular.to_sym
              import(contract_class, as: alias_name)
              imported_type = [alias_name, TYPE_NAME].join('_').to_sym
              type?(imported_type) ? imported_type : nil
            end

            def includable_params?(representation_class, depth:, visited:)
              return false if depth >= MAX_RECURSION_DEPTH

              new_visited = visited.dup.add(representation_class)

              representation_class.associations.values.any? do |association|
                if association.polymorphic?
                  association.include != :always
                else
                  nested_representation_class = resolve_association_representation_class(representation_class, association)
                  next false unless nested_representation_class

                  if new_visited.include?(nested_representation_class)
                    association.include != :always
                  elsif association.include == :always
                    includable_params?(nested_representation_class, depth: depth + 1, visited: new_visited)
                  else
                    true
                  end
                end
              end
            end

            def type_name_for(representation_class, depth)
              return TYPE_NAME if depth.zero?

              [representation_class.root_key.singular, TYPE_NAME].join('_').to_sym
            end

            def resolve_association_representation_class(representation_class, association)
              IncludesResolver.resolve_representation_class(representation_class, association)
            end
          end
        end
      end
    end
  end
end
