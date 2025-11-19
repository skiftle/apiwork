# frozen_string_literal: true

module Apiwork
  module Generator
    # Pure type analysis service
    # Provides type dependency analysis, topological sorting, and circular reference detection
    # Used by type-based generators (TypeScript, Zod, etc.)
    class TypeAnalysis
      class << self
        # Sort types in topological order to avoid forward references
        # Types that don't depend on other types come first
        def topological_sort_types(all_types)
          reverse_deps = Hash.new { |h, k| h[k] = [] }

          all_types.each do |type_name, type_shape|
            referenced_types = type_references(type_shape, filter: all_types.keys)

            referenced_types.each do |referenced_type|
              next if referenced_type == type_name # Skip self-references (recursive types)

              reverse_deps[referenced_type] << type_name
            end
          end

          # Topological sort using Kahn's algorithm
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
            unsorted_types = all_types.keys - sorted
            (sorted + unsorted_types).map { |type_name| [type_name, all_types[type_name]] }
          end
        end

        # Extract all type references from a definition
        def type_references(definition, filter: :custom_only)
          referenced_types = []

          # Handle top-level union variants (for union types themselves)
          if definition[:variants].is_a?(Array)
            definition[:variants].each do |variant|
              next unless variant.is_a?(Hash)

              add_type_if_matches(referenced_types, variant[:type], filter)
              add_type_if_matches(referenced_types, variant[:of], filter)

              # Recursively check nested shape in variants
              referenced_types.concat(type_references(variant[:shape], filter: filter)) if variant[:shape].is_a?(Hash)
            end
          end

          # For object types, fields are now under :shape key
          # For other structures, iterate over all values
          fields_to_check = if definition[:type] == :object && definition[:shape].is_a?(Hash)
                              definition[:shape]
                            else
                              definition
                            end

          # Handle nested params (for object types, etc.)
          fields_to_check.each_value do |param|
            next unless param.is_a?(Hash)

            # Direct type reference
            add_type_if_matches(referenced_types, param[:type], filter)

            # Array 'of' reference
            add_type_if_matches(referenced_types, param[:of], filter)

            # Union variant references (for nested unions)
            if param[:variants].is_a?(Array)
              param[:variants].each do |variant|
                next unless variant.is_a?(Hash)

                add_type_if_matches(referenced_types, variant[:type], filter)
                add_type_if_matches(referenced_types, variant[:of], filter)

                # Recursively check nested shape in variants
                referenced_types.concat(type_references(variant[:shape], filter: filter)) if variant[:shape].is_a?(Hash)
              end
            end

            # Recursively check nested shapes
            referenced_types.concat(type_references(param[:shape], filter: filter)) if param[:shape].is_a?(Hash)
          end

          referenced_types.uniq
        end

        # Detect if a type has circular references to itself
        def circular_reference?(type_name, type_def, filter: :custom_only)
          refs = type_references(type_def, filter: filter)
          refs.include?(type_name)
        end

        # Check if type is a primitive
        def primitive_type?(type)
          %i[
            string integer boolean datetime date uuid object array
            decimal float literal union enum text binary json number time
          ].include?(type)
        end

        private

        # Helper to add a type reference if it matches the filter criteria
        def add_type_if_matches(collection, type_ref, filter)
          return unless type_ref

          # Normalize to symbol
          type_sym = type_ref.is_a?(String) ? type_ref.to_sym : type_ref
          return unless type_sym.is_a?(Symbol)

          case filter
          when :custom_only
            collection << type_sym unless primitive_type?(type_sym)
          when Array
            collection << type_sym if filter.include?(type_sym)
          end
        end
      end
    end
  end
end
