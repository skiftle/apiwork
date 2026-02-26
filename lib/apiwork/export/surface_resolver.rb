# frozen_string_literal: true

module Apiwork
  module Export
    class SurfaceResolver
      class << self
        def resolve(api)
          new(api)
        end
      end

      def initialize(api)
        @api = api
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
        @api.types.select { |name, _| type_names.include?(name) }
      end

      def compute_reachable_enums
        enum_names = collect_enum_names_from_actions
        collect_enum_names_from_types(types, enum_names)
        @api.enums.select { |name, _| enum_names.include?(name) }
      end

      def collect_type_names_from_actions
        type_names = Set.new
        @api.resources.each_value do |resource|
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
        type_names << :error if action.raises.any? && @api.types.key?(:error)
      end

      def collect_types_from_param(param, type_names)
        type_names << param.reference if param.reference?

        param.shape.each_value { |nested| collect_types_from_param(nested, type_names) } if param.object?

        if param.array?
          collect_types_from_param(param.of, type_names) if param.of
          param.shape.each_value { |nested| collect_types_from_param(nested, type_names) }
        end

        return unless param.union?

        param.variants.each { |variant| collect_types_from_param(variant, type_names) }
      end

      def expand_transitive_dependencies(type_names)
        added = true

        while added
          added = false
          type_names.dup.each do |type_name|
            type = @api.types[type_name]
            next unless type

            collect_reference_names_from_type(type).each do |reference_name|
              next unless @api.types.key?(reference_name)
              next if type_names.include?(reference_name)

              type_names << reference_name
              added = true
            end
          end
        end
      end

      def collect_reference_names_from_type(type)
        reference_names = []

        if type.object?
          reference_names.concat(type.extends) if type.extends?
          type.shape.each_value { |param| collect_reference_names_from_param(param, reference_names) }
        elsif type.union?
          type.variants.each { |param| collect_reference_names_from_param(param, reference_names) }
        end

        reference_names.uniq
      end

      def collect_reference_names_from_param(param, reference_names)
        reference_names << param.reference if param.reference?

        param.shape.each_value { |nested| collect_reference_names_from_param(nested, reference_names) } if param.object?

        if param.array?
          collect_reference_names_from_param(param.of, reference_names) if param.of
          param.shape.each_value { |nested| collect_reference_names_from_param(nested, reference_names) }
        end

        param.variants.each { |variant| collect_reference_names_from_param(variant, reference_names) } if param.union?
      end

      def collect_enum_names_from_actions
        enum_names = Set.new
        @api.resources.each_value do |resource|
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
        enum_names << param.enum if param.enum_reference?

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
          collect_enums_from_type(type, enum_names)
        end
      end

      def collect_enums_from_type(type, enum_names)
        if type.object?
          type.shape.each_value { |param| collect_enums_from_type_param(param, enum_names) }
        elsif type.union?
          type.variants.each { |param| collect_enums_from_type_param(param, enum_names) }
        end
      end

      def collect_enums_from_type_param(param, enum_names)
        enum_names << param.enum if param.enum_reference?
        enum_names << param.reference if param.reference? && @api.enums.key?(param.reference)

        param.shape.each_value { |nested| collect_enums_from_type_param(nested, enum_names) } if param.object?

        if param.array?
          collect_enums_from_type_param(param.of, enum_names) if param.of
          param.shape.each_value { |nested| collect_enums_from_type_param(nested, enum_names) }
        end

        param.variants.each { |variant| collect_enums_from_type_param(variant, enum_names) } if param.union?
      end
    end
  end
end
