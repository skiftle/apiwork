# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class IncludesResolver
        attr_reader :schema_class

        def initialize(schema_class)
          @schema_class = schema_class
        end

        def always_included(visited = Set.new)
          associations = schema_class.associations.select { |_, a| a.include == :always }
          extract_associations(associations, visited)
        end

        def from_params(params, visited = Set.new)
          extract_from_hash(params, visited)
        end

        def self.merge(base, override)
          return base if override.blank?

          base.deep_merge(override.deep_symbolize_keys)
        end

        private

        def extract_associations(associations, visited = Set.new)
          return {} if visited.include?(schema_class.name)

          visited = visited.dup.add(schema_class.name)

          associations.each_with_object({}) do |(name, association), result|
            nested_schema = resolve_schema_class(association, name)
            result[name] = if nested_schema
                             self.class.new(nested_schema).always_included(visited)
                           else
                             {}
                           end
          end
        end

        def extract_from_hash(hash, visited = Set.new)
          return {} if hash.blank?
          return {} if visited.include?(schema_class.name)

          visited = visited.dup.add(schema_class.name)

          if hash.is_a?(Array)
            return hash.each_with_object({}) do |item, result|
              result.deep_merge!(extract_from_hash(item, visited))
            end
          end

          hash.each_with_object({}) do |(key, value), result|
            key = key.to_sym

            if %i[_or _and].include?(key) && value.is_a?(Array)
              value.each { |item| result.deep_merge!(extract_from_hash(item, visited)) }
              next
            elsif key == :_not && value.is_a?(Hash)
              result.deep_merge!(extract_from_hash(value, visited))
              next
            end

            association = schema_class.associations[key]
            next unless association

            nested = if value.is_a?(Hash) && association.schema_class.respond_to?(:associations)
                       self.class.new(association.schema_class).from_params(value, visited)
                     else
                       {}
                     end

            result[key] = nested
          end
        end

        def resolve_schema_class(association, name)
          return association.schema_class if association.schema_class

          reflection = schema_class.model_class.reflect_on_association(name)
          return nil if reflection.nil? || reflection.polymorphic?

          namespace = schema_class.name.deconstantize
          "#{namespace}::#{reflection.klass.name.demodulize}Schema".safe_constantize
        end
      end
    end
  end
end
