# frozen_string_literal: true

module Apiwork
  module Export
    class TypeAnalysis
      class << self
        def topological_sort_types(all_types)
          lazy_types = cycle_breaking_types(all_types)
          kahn_sort(all_types, lazy_types)
        end

        def cycle_breaking_types(all_types)
          sccs = find_strongly_connected_components(all_types)
          lazy_types = Set.new

          sccs.each do |scc|
            next if scc.size == 1 && !self_referential?(scc.first, all_types)

            lazy_types.add(scc.min_by(&:to_s))
          end

          lazy_types
        end

        def find_strongly_connected_components(all_types)
          graph = {}
          all_types.each do |type_name, type_shape|
            graph[type_name] = type_references(type_shape, filter: all_types.keys)
          end

          tarjan_scc(graph)
        end

        def self_referential?(type_name, all_types)
          type_references(all_types[type_name], filter: all_types.keys).include?(type_name)
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

        def types_in_cycles(all_types)
          graph = {}
          all_types.each do |type_name, type_shape|
            graph[type_name] = type_references(type_shape, filter: all_types.keys)
          end

          visited = Set.new
          in_stack = Set.new
          cyclic_types = Set.new

          find_cycles = lambda do |node, path|
            return if visited.include?(node)

            visited.add(node)
            in_stack.add(node)
            path.push(node)

            (graph[node] || []).each do |neighbor|
              if in_stack.include?(neighbor)
                cycle_start_index = path.index(neighbor)
                path[cycle_start_index..].each { |n| cyclic_types.add(n) }
              elsif !visited.include?(neighbor)
                find_cycles.call(neighbor, path)
              end
            end

            path.pop
            in_stack.delete(node)
          end

          all_types.each_key do |type_name|
            find_cycles.call(type_name, []) unless visited.include?(type_name)
          end

          cyclic_types
        end

        def primitive_type?(type)
          %i[
            string integer boolean datetime date uuid object array
            decimal float literal union enum text binary json number time
            unknown
          ].include?(type)
        end

        private

        def kahn_sort(all_types, lazy_types)
          forward_deps = Hash.new { |hash, key| hash[key] = [] }

          all_types.each do |type_name, type_shape|
            next if lazy_types.include?(type_name)

            referenced_types = type_references(type_shape, filter: all_types.keys)
            referenced_types.each do |dep|
              next if dep == type_name
              next if lazy_types.include?(dep)

              forward_deps[type_name] << dep
            end
          end

          sorted = lazy_types.to_a.sort_by(&:to_s)
          remaining = all_types.keys - sorted
          dependency_count = Hash.new(0)

          remaining.each do |type_name|
            dependency_count[type_name] = forward_deps[type_name].size
          end

          queue = remaining.select { |type| dependency_count[type].zero? }.sort_by(&:to_s)

          while queue.any?
            current = queue.shift
            sorted << current

            remaining.each do |type_name|
              next unless forward_deps[type_name].include?(current)

              dependency_count[type_name] -= 1
              queue << type_name if dependency_count[type_name].zero?
            end

            queue.sort_by!(&:to_s)
          end

          unsorted = remaining - sorted
          sorted.concat(unsorted.sort_by(&:to_s))

          sorted.map { |type_name| [type_name, all_types[type_name]] }
        end

        def tarjan_scc(graph)
          index_counter = [0]
          stack = []
          lowlinks = {}
          index = {}
          on_stack = {}
          sccs = []

          strongconnect = lambda do |node|
            index[node] = index_counter[0]
            lowlinks[node] = index_counter[0]
            index_counter[0] += 1
            stack.push(node)
            on_stack[node] = true

            (graph[node] || []).each do |successor|
              if index[successor].nil?
                strongconnect.call(successor)
                lowlinks[node] = [lowlinks[node], lowlinks[successor]].min
              elsif on_stack[successor]
                lowlinks[node] = [lowlinks[node], index[successor]].min
              end
            end

            if lowlinks[node] == index[node]
              scc = []
              loop do
                successor = stack.pop
                on_stack[successor] = false
                scc << successor
                break if successor == node
              end
              sccs << scc
            end
          end

          graph.each_key do |node|
            strongconnect.call(node) if index[node].nil?
          end

          sccs
        end

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
