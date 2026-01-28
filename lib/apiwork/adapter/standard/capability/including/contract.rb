# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class Contract < Adapter::Capability::Contract::Base
            MAX_RECURSION_DEPTH = 3

            def build
              build_include_type(representation_class, depth: 0, visited: Set.new)
              return unless type?(:include)

              actions.each_key do |action_name|
                action(action_name) do
                  request do
                    query do
                      reference? :include
                    end
                  end
                end
              end
            end

            private

            def build_include_type(target_representation, depth:, visited:)
              return nil unless target_representation.associations.any?
              return nil unless includable_params?(target_representation, depth:, visited:)

              type_name = type_name_for(target_representation, depth)
              return type_name if type?(type_name)
              return type_name if depth >= MAX_RECURSION_DEPTH

              visited = visited.dup.add(target_representation)

              association_params = compute_association_params(
                target_representation,
                depth:,
                visited:,
              )

              object(type_name) do
                association_params.each do |param_data|
                  name = param_data[:name]
                  include_mode = param_data[:include_mode]
                  param_type = param_data[:param_type]
                  include_type = param_data[:include_type]

                  case param_type
                  when :boolean
                    boolean name, optional: true unless include_mode == :always
                  when :reference
                    reference name, optional: true, to: include_type
                  when :union
                    assoc_type = include_type
                    union name, optional: true do
                      variant { boolean }
                      variant { reference assoc_type }
                    end
                  end
                end
              end

              type_name
            end

            def compute_association_params(target_representation, depth:, visited:)
              target_representation.associations.filter_map do |name, association|
                compute_single_association_param(name, association, target_representation, depth:, visited:)
              end
            end

            def compute_single_association_param(name, association, target_representation, depth:, visited:)
              if association.polymorphic?
                return {
                  name:,
                  include_mode: association.include,
                  include_type: nil,
                  param_type: :boolean,
                }
              end

              association_representation = resolve_association_representation(target_representation, association)
              return nil unless association_representation

              if visited.include?(association_representation)
                return {
                  name:,
                  include_mode: association.include,
                  include_type: nil,
                  param_type: :boolean,
                }
              end

              association_include_type = resolve_association_include_type(
                association_representation,
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

            def resolve_association_include_type(association_representation, depth:, visited:)
              association_contract = find_contract_for_representation(association_representation)

              if association_contract
                alias_name = association_representation.root_key.singular.to_sym
                import(association_contract, as: alias_name)
                imported_type = :"#{alias_name}_include"
                type?(imported_type) ? imported_type : nil
              else
                build_include_type(
                  association_representation,
                  visited:,
                  depth: depth + 1,
                )
              end
            end

            def includable_params?(target_representation, depth:, visited:)
              return false if depth >= MAX_RECURSION_DEPTH

              new_visited = visited.dup.add(target_representation)

              target_representation.associations.values.any? do |association|
                if association.polymorphic?
                  association.include != :always
                else
                  association_representation = resolve_association_representation(target_representation, association)
                  next false unless association_representation

                  if new_visited.include?(association_representation)
                    association.include != :always
                  elsif association.include == :always
                    includable_params?(association_representation, depth: depth + 1, visited: new_visited)
                  else
                    true
                  end
                end
              end
            end

            def type_name_for(representation, depth)
              return :include if depth.zero?

              representation_name = representation.name.demodulize.delete_suffix('Representation').underscore
              :"#{representation_name}_include"
            end

            def resolve_association_representation(parent_representation, association)
              return nil if association.polymorphic?
              return association.representation_class if association.representation_class

              model_class = association.model_class
              return nil unless model_class

              reflection = model_class.reflect_on_association(association.name)
              return nil unless reflection
              return nil if reflection.polymorphic?

              namespace = parent_representation.name.deconstantize
              "#{namespace}::#{reflection.klass.name.demodulize}Representation".safe_constantize
            end
          end
        end
      end
    end
  end
end
