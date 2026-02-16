# frozen_string_literal: true

module Apiwork
  module Export
    class TypeAnalysis
      PRIMITIVE_TYPES = %i[
        string integer boolean datetime date uuid object array
        decimal float literal union enum text binary json number time
        unknown
      ].to_set.freeze

      class << self
        def topological_sort_types(all_types)
          graph = build_dependency_graph(all_types)
          lazy_types = find_cycle_breaking_types(graph)
          sort_with_lazy_types(all_types, graph, lazy_types)
        end

        def cycle_breaking_types(all_types)
          find_cycle_breaking_types(build_dependency_graph(all_types))
        end

        def type_references(definition, filter: :custom_only)
          references = []
          collect_references(definition, references, filter)
          references.uniq
        end

        def primitive_type?(type)
          PRIMITIVE_TYPES.include?(type)
        end

        private

        def build_dependency_graph(all_types)
          type_keys = all_types.keys
          all_types.transform_values { |shape| type_references(shape, filter: type_keys) }
        end

        def find_cycle_breaking_types(graph)
          lazy_types = Set.new

          find_strongly_connected_components(graph).each do |component|
            next if component.size == 1 && !graph[component.first].include?(component.first)

            lazy_types.add(component.min_by(&:to_s))
          end

          lazy_types
        end

        def sort_with_lazy_types(all_types, graph, lazy_types)
          dependencies = build_non_lazy_dependencies(all_types, graph, lazy_types)
          sorted = lazy_types.to_a.sort_by(&:to_s)
          remaining = dependencies.keys.sort_by(&:to_s)

          until remaining.empty?
            ready = remaining.select { |type_name| dependencies[type_name].empty? }
            break if ready.empty?

            ready.sort_by(&:to_s).each do |type_name|
              sorted << type_name
              remaining.delete(type_name)
              dependencies.each_value { |type_dependencies| type_dependencies.delete(type_name) }
            end
          end

          sorted.concat(remaining.sort_by(&:to_s))
          sorted.map { |type_name| [type_name, all_types[type_name]] }
        end

        def build_non_lazy_dependencies(all_types, graph, lazy_types)
          all_types.each_key.with_object({}) do |type_name, dependencies|
            next if lazy_types.include?(type_name)

            dependencies[type_name] = (graph[type_name] - lazy_types.to_a - [type_name]).to_set
          end
        end

        def find_strongly_connected_components(graph)
          state = { components: [], index: 0, indices: {}, lowlinks: {}, on_stack: Set.new, stack: [] }

          graph.each_key do |node|
            tarjan_visit(node, graph, state) unless state[:indices][node]
          end

          state[:components]
        end

        def tarjan_visit(node, graph, state)
          state[:indices][node] = state[:lowlinks][node] = state[:index]
          state[:index] += 1
          state[:stack].push(node)
          state[:on_stack].add(node)

          (graph[node] || []).each do |successor|
            if state[:indices][successor].nil?
              tarjan_visit(successor, graph, state)
              state[:lowlinks][node] = [state[:lowlinks][node], state[:lowlinks][successor]].min
            elsif state[:on_stack].include?(successor)
              state[:lowlinks][node] = [state[:lowlinks][node], state[:indices][successor]].min
            end
          end

          return unless state[:lowlinks][node] == state[:indices][node]

          component = []
          loop do
            successor = state[:stack].pop
            state[:on_stack].delete(successor)
            component << successor
            break if successor == node
          end
          state[:components] << component
        end

        def collect_references(node, references, filter)
          return unless node.is_a?(Hash)

          extract_type_field(node, references, filter)
          extract_of_field(node[:of], references, filter)
          extract_extends_field(node[:extends], references, filter)

          node[:variants]&.each { |variant| collect_references(variant, references, filter) }
          node[:shape]&.each_value { |param| collect_references(param, references, filter) }
        end

        def extract_type_field(node, references, filter)
          type_value = node[:type]
          return unless type_value

          type_to_add = [:reference, 'reference'].include?(type_value) ? node[:reference] : type_value
          add_if_matches_filter(references, type_to_add, filter)
        end

        def extract_of_field(of, references, filter)
          return unless of

          if of.is_a?(Hash)
            collect_references(of, references, filter)
          else
            add_if_matches_filter(references, of, filter)
          end
        end

        def extract_extends_field(extends, references, filter)
          extends&.each do |extended_type|
            if extended_type.is_a?(Hash)
              collect_references(extended_type, references, filter)
            else
              add_if_matches_filter(references, extended_type, filter)
            end
          end
        end

        def add_if_matches_filter(references, type_symbol, filter)
          type_symbol = type_symbol.to_sym if type_symbol.is_a?(String)
          return unless type_symbol.is_a?(Symbol)

          case filter
          when :custom_only
            references << type_symbol unless primitive_type?(type_symbol)
          when Array
            references << type_symbol if filter.include?(type_symbol)
          end
        end
      end
    end
  end
end
