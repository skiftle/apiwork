# frozen_string_literal: true

module Apiwork
  module Export
    class TypeAnalysis
      class << self
        def topological_sort_types(all_types)
          graph = build_graph(all_types)
          lazy_types = find_cycle_breaking_types(graph)
          kahn_sort(all_types, graph, lazy_types)
        end

        def cycle_breaking_types(all_types)
          graph = build_graph(all_types)
          find_cycle_breaking_types(graph)
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

        PRIMITIVE_TYPES = %i[
          string integer boolean datetime date uuid object array
          decimal float literal union enum text binary json number time
          unknown
        ].to_set.freeze

        def build_graph(all_types)
          type_keys = all_types.keys
          all_types.transform_values { |shape| type_references(shape, filter: type_keys) }
        end

        def find_cycle_breaking_types(graph)
          components = tarjan_strongly_connected_components(graph)
          lazy_types = Set.new

          components.each do |component|
            next if component.size == 1 && !graph[component.first].include?(component.first)

            lazy_types.add(component.min_by(&:to_s))
          end

          lazy_types
        end

        def kahn_sort(all_types, graph, lazy_types)
          non_lazy_dependencies = {}
          all_types.each_key do |type_name|
            next if lazy_types.include?(type_name)

            non_lazy_dependencies[type_name] = (graph[type_name] - lazy_types.to_a - [type_name]).to_set
          end

          sorted = lazy_types.to_a.sort_by(&:to_s)
          remaining = non_lazy_dependencies.keys.sort_by(&:to_s)

          until remaining.empty?
            ready = remaining.select { |type_name| non_lazy_dependencies[type_name].empty? }
            break if ready.empty?

            ready.sort_by(&:to_s).each do |type_name|
              sorted << type_name
              remaining.delete(type_name)
              non_lazy_dependencies.each_value { |dependencies| dependencies.delete(type_name) }
            end
          end

          sorted.concat(remaining.sort_by(&:to_s))
          sorted.map { |type_name| [type_name, all_types[type_name]] }
        end

        def tarjan_strongly_connected_components(graph)
          index_counter = [0]
          stack = []
          lowlinks = {}
          index = {}
          on_stack = Set.new
          components = []

          strongconnect = lambda do |node|
            index[node] = lowlinks[node] = index_counter[0]
            index_counter[0] += 1
            stack.push(node)
            on_stack.add(node)

            (graph[node] || []).each do |successor|
              if index[successor].nil?
                strongconnect.call(successor)
                lowlinks[node] = [lowlinks[node], lowlinks[successor]].min
              elsif on_stack.include?(successor)
                lowlinks[node] = [lowlinks[node], index[successor]].min
              end
            end

            if lowlinks[node] == index[node]
              component = []
              loop do
                successor = stack.pop
                on_stack.delete(successor)
                component << successor
                break if successor == node
              end
              components << component
            end
          end

          graph.each_key { |node| strongconnect.call(node) if index[node].nil? }
          components
        end

        def collect_references(definition, references, filter)
          return unless definition.is_a?(Hash)

          add_reference(references, definition, filter)
          add_reference(references, definition[:of], filter)

          definition[:extends]&.each { |extended_type| add_reference(references, extended_type, filter) }

          definition[:variants]&.each do |variant|
            next unless variant.is_a?(Hash)

            add_reference(references, variant, filter)
            add_reference(references, variant[:of], filter)
            collect_references(variant[:shape], references, filter)
          end

          shape = definition[:type] == :object ? definition[:shape] : definition
          shape&.each_value do |param|
            next unless param.is_a?(Hash)

            add_reference(references, param, filter)
            add_reference(references, param[:of], filter)
            collect_references(param[:shape], references, filter)

            param[:variants]&.each do |variant|
              next unless variant.is_a?(Hash)

              add_reference(references, variant, filter)
              add_reference(references, variant[:of], filter)
              collect_references(variant[:shape], references, filter)
            end
          end
        end

        def add_reference(collection, type_reference, filter)
          return unless type_reference

          resolved_type = case type_reference
                          when Hash
                            if [:reference, 'reference'].include?(type_reference[:type])
                              type_reference[:reference]
                            else
                              type_reference[:type]
                            end
                          else
                            type_reference
                          end

          resolved_type = resolved_type.to_sym if resolved_type.is_a?(String)
          return unless resolved_type.is_a?(Symbol)

          case filter
          when :custom_only
            collection << resolved_type unless primitive_type?(resolved_type)
          when Array
            collection << resolved_type if filter.include?(resolved_type)
          end
        end
      end
    end
  end
end
