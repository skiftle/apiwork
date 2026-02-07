# frozen_string_literal: true

module Apiwork
  module Export
    class TypeAnalysis
      class << self
        def topological_sort_types(all_types)
          reverse_deps = Hash.new { |hash, key| hash[key] = [] }

          all_types.each do |type_name, type_shape|
            referenced_types = type_references(type_shape, filter: all_types.keys)

            referenced_types.each do |referenced_type|
              next if referenced_type == type_name

              reverse_deps[referenced_type] << type_name
            end
          end

          sorted = []
          dependency_count = Hash.new(0)

          reverse_deps.each_value do |dependents|
            dependents.each { |dependent| dependency_count[dependent] += 1 }
          end

          queue = all_types.keys.select { |type| dependency_count[type].zero? }

          while queue.any?
            current = queue.shift
            sorted << current

            reverse_deps[current].each do |dependent|
              dependency_count[dependent] -= 1
              queue << dependent if dependency_count[dependent].zero?
            end
          end

          if sorted.size == all_types.size
            sorted.map { |type_name| [type_name, all_types[type_name]] }
          else
            (sorted + (all_types.keys - sorted)).map { |type_name| [type_name, all_types[type_name]] }
          end
        end

        def type_references(definition, filter: :custom_only)
          referenced_types = []

          if definition[:extends].is_a?(Array)
            definition[:extends].each do |extended_type|
              add_type_if_matches(referenced_types, extended_type, filter)
            end
          end

          if definition[:variants].is_a?(Array)
            definition[:variants].each do |variant|
              next unless variant.is_a?(Hash)

              add_type_if_matches(referenced_types, variant, filter)
              add_type_if_matches(referenced_types, variant[:of], filter)

              referenced_types.concat(type_references(variant[:shape], filter:)) if variant[:shape].is_a?(Hash)
            end
          end

          fields_to_check = if definition[:type] == :object && definition[:shape].is_a?(Hash)
                              definition[:shape]
                            else
                              definition
                            end

          fields_to_check.each_value do |param|
            next unless param.is_a?(Hash)

            add_type_if_matches(referenced_types, param, filter)

            add_type_if_matches(referenced_types, param[:of], filter)

            if param[:variants].is_a?(Array)
              param[:variants].each do |variant|
                next unless variant.is_a?(Hash)

                add_type_if_matches(referenced_types, variant, filter)
                add_type_if_matches(referenced_types, variant[:of], filter)

                referenced_types.concat(type_references(variant[:shape], filter:)) if variant[:shape].is_a?(Hash)
              end
            end

            referenced_types.concat(type_references(param[:shape], filter:)) if param[:shape].is_a?(Hash)
          end

          referenced_types.uniq
        end

        def circular_reference?(type_name, type_definition, filter: :custom_only)
          type_references(type_definition, filter:).include?(type_name)
        end

        def primitive_type?(type)
          %i[
            string integer boolean datetime date uuid object array
            decimal float literal union enum text binary json number time
            unknown
          ].include?(type)
        end

        private

        def add_type_if_matches(collection, type_reference, filter)
          return unless type_reference

          if type_reference.is_a?(Hash)
            type_value = type_reference[:type]
            type_reference = if [:reference, 'reference'].include?(type_value)
                               type_reference[:reference]
                             else
                               type_value
                             end
          end

          type_reference = type_reference.to_sym if type_reference.is_a?(String)
          return unless type_reference.is_a?(Symbol)

          case filter
          when :custom_only
            collection << type_reference unless primitive_type?(type_reference)
          when Array
            collection << type_reference if filter.include?(type_reference)
          end
        end
      end
    end
  end
end
