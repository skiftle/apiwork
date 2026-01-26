# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class Contract < Adapter::Capability::Contract::Base
            MAX_RECURSION_DEPTH = 3

            def build
              self.class.build_include_type(registrar, representation_class, depth: 0, visited: Set.new)
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

            class << self
              def build_include_type(registrar, target_representation, depth:, visited:)
                return nil unless target_representation.associations.any?
                return nil unless has_includable_params?(registrar, target_representation, depth:, visited:)

                type_name = type_name_for(target_representation, depth)
                return type_name if registrar.type?(type_name)
                return type_name if depth >= MAX_RECURSION_DEPTH

                visited = visited.dup.add(target_representation)
                registrar_ref = registrar
                target_ref = target_representation
                visited_ref = visited
                current_depth = depth

                registrar.object(type_name) do
                  target_ref.associations.each do |name, association|
                    if association.polymorphic?
                      boolean name, optional: true unless association.include == :always
                      next
                    end

                    association_representation = Contract.resolve_association_representation(target_ref, association)
                    next unless association_representation

                    if visited_ref.include?(association_representation)
                      boolean name, optional: true unless association.include == :always
                    else
                      association_contract = registrar_ref.find_contract_for_representation(association_representation)

                      association_include_type = if association_contract
                                                   alias_name = association_representation.root_key.singular.to_sym
                                                   registrar_ref.import(association_contract, as: alias_name)
                                                   imported_type = :"#{alias_name}_include"
                                                   registrar_ref.type?(imported_type) ? imported_type : nil
                                                 else
                                                   Contract.build_include_type(
                                                     registrar_ref,
                                                     association_representation,
                                                     depth: current_depth + 1,
                                                     visited: visited_ref,
                                                   )
                                                 end

                      if association_include_type.nil?
                        boolean name, optional: true unless association.include == :always
                      elsif association.include == :always
                        reference name, optional: true, to: association_include_type
                      else
                        assoc_type = association_include_type
                        union name, optional: true do
                          variant { boolean }
                          variant { reference assoc_type }
                        end
                      end
                    end
                  end
                end

                type_name
              end

              def has_includable_params?(registrar, target_representation, depth:, visited:)
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
                      has_includable_params?(registrar, association_representation, depth: depth + 1, visited: new_visited)
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
end
