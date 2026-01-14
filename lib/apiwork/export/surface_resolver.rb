# frozen_string_literal: true

module Apiwork
  module Export
    class SurfaceResolver
      def initialize(data)
        @data = data
      end

      def types
        @types ||= compute_reachable_types
      end

      def enums
        @enums ||= compute_reachable_enums
      end

      private

      def compute_reachable_types
        type_names = collect_type_names_from_actions
        expand_transitive_dependencies(type_names)
        @data.types.select { |name, _| type_names.include?(name) }
      end

      def compute_reachable_enums
        enum_names = collect_enum_names_from_actions
        collect_enum_names_from_types(types, enum_names)
        @data.enums.select { |name, _| enum_names.include?(name) }
      end

      def collect_type_names_from_actions
        type_names = Set.new
        @data.resources.each_value do |resource|
          collect_types_from_resource(resource, type_names)
        end
        type_names
      end

      def collect_types_from_resource(resource, type_names)
        resource.actions.each_value do |action|
          collect_types_from_action(action, type_names)
        end
        resource.resources.each_value do |nested|
          collect_types_from_resource(nested, type_names)
        end
      end

      def collect_types_from_action(action, type_names)
        action.request.query.each_value { |param| collect_types_from_param(param, type_names) }
        action.request.body.each_value { |param| collect_types_from_param(param, type_names) }
        collect_types_from_param(action.response.body, type_names) if action.response.body
      end

      def collect_types_from_param(param, type_names)
        type_names << param.ref if param.ref?

        param.shape.each_value { |nested| collect_types_from_param(nested, type_names) } if param.object?

        if param.array?
          collect_types_from_param(param.of, type_names) if param.of
          param.shape.each_value { |nested| collect_types_from_param(nested, type_names) }
        end

        return unless param.union?

        param.variants.each { |variant| collect_types_from_param(variant, type_names) }
      end

      def expand_transitive_dependencies(type_names)
        all_type_data = @data.types.transform_values(&:to_h)
        added = true

        while added
          added = false
          type_names.dup.each do |type_name|
            type_data = all_type_data[type_name]
            next unless type_data

            refs = collect_refs_from_type_data(type_data, all_type_data.keys)
            refs.each do |ref|
              next if type_names.include?(ref)

              type_names << ref
              added = true
            end
          end
        end
      end

      def collect_refs_from_type_data(type_data, known_types)
        refs = []
        collect_refs_from_shape(type_data[:shape], known_types, refs)
        collect_refs_from_variants(type_data[:variants], known_types, refs)
        refs.uniq
      end

      def collect_refs_from_shape(shape, known_types, refs)
        return unless shape.is_a?(Hash)

        shape.each_value do |field|
          next unless field.is_a?(Hash)

          refs << field[:ref] if field[:ref].is_a?(Symbol) && known_types.include?(field[:ref])

          collect_of_ref(field[:of], known_types, refs)
          collect_refs_from_shape(field[:shape], known_types, refs)
          collect_refs_from_variants(field[:variants], known_types, refs)
        end
      end

      def collect_refs_from_variants(variants, known_types, refs)
        return unless variants.is_a?(Array)

        variants.each do |variant|
          next unless variant.is_a?(Hash)

          refs << variant[:ref] if variant[:ref].is_a?(Symbol) && known_types.include?(variant[:ref])

          collect_of_ref(variant[:of], known_types, refs)
          collect_refs_from_shape(variant[:shape], known_types, refs)
        end
      end

      def collect_of_ref(of_data, known_types, refs)
        return unless of_data.is_a?(Hash)

        refs << of_data[:ref] if of_data[:ref].is_a?(Symbol) && known_types.include?(of_data[:ref])
      end

      def collect_enum_names_from_actions
        enum_names = Set.new
        @data.resources.each_value do |resource|
          collect_enums_from_resource(resource, enum_names)
        end
        enum_names
      end

      def collect_enums_from_resource(resource, enum_names)
        resource.actions.each_value do |action|
          collect_enums_from_action(action, enum_names)
        end
        resource.resources.each_value do |nested|
          collect_enums_from_resource(nested, enum_names)
        end
      end

      def collect_enums_from_action(action, enum_names)
        action.request.query.each_value { |param| collect_enums_from_param(param, enum_names) }
        action.request.body.each_value { |param| collect_enums_from_param(param, enum_names) }
        collect_enums_from_param(action.response.body, enum_names) if action.response.body
      end

      def collect_enums_from_param(param, enum_names)
        enum_names << param.enum if param.enum_ref?

        param.shape.each_value { |nested| collect_enums_from_param(nested, enum_names) } if param.object?

        if param.array?
          collect_enums_from_param(param.of, enum_names) if param.of
          param.shape.each_value { |nested| collect_enums_from_param(nested, enum_names) }
        end

        return unless param.union?

        param.variants.each { |variant| collect_enums_from_param(variant, enum_names) }
      end

      def collect_enum_names_from_types(resolved_types, enum_names)
        resolved_types.each_value do |type|
          collect_enums_from_type_data(type.to_h, enum_names)
        end
      end

      def collect_enums_from_type_data(type_data, enum_names)
        shape = type_data[:shape] || {}
        shape.each_value do |field|
          next unless field.is_a?(Hash)

          enum_names << field[:enum] if field[:enum].is_a?(Symbol)
          enum_names << field[:ref] if field[:ref].is_a?(Symbol) && @data.enums.key?(field[:ref])

          of_ref = field[:of][:ref] if field[:of].is_a?(Hash)
          enum_names << of_ref if of_ref.is_a?(Symbol) && @data.enums.key?(of_ref)

          collect_enums_from_type_data(field, enum_names) if field[:shape]
        end

        return unless type_data[:variants].is_a?(Array)

        type_data[:variants].each do |variant|
          collect_enums_from_type_data(variant, enum_names) if variant.is_a?(Hash)
        end
      end
    end
  end
end
