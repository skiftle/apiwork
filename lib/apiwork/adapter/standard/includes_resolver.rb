# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class IncludesResolver
        attr_reader :representation_class

        class << self
          def resolve(representation_class, params = {}, include_always: false)
            new(representation_class).resolve(params, include_always:)
          end
        end

        def initialize(representation_class)
          @representation_class = representation_class
        end

        def resolve(params = {}, include_always: false)
          base = include_always ? always_included : {}
          merged = merge(base, from_params(params))
          format(merged)
        end

        def always_included(visited = Set.new)
          associations = representation_class.associations.select { |_, a| a.include == :always }
          extract_associations(associations, visited)
        end

        def from_params(params, visited = Set.new)
          extract_from_hash(params, visited)
        end

        def merge(base, override)
          return base if override.blank?

          base.deep_merge(override.deep_symbolize_keys)
        end

        def format(hash)
          return [] if hash.blank?

          result = hash.map do |key, value|
            if value.blank?
              key
            else
              { key => format(value) }
            end
          end

          result.size == 1 ? result.first : result
        end

        private

        def extract_associations(associations, visited = Set.new)
          return {} if visited.include?(representation_class.name)

          visited = visited.dup.add(representation_class.name)

          associations.each_with_object({}) do |(name, association), result|
            nested_representation_class = association.representation_class
            result[name] = if nested_representation_class
                             self.class.new(nested_representation_class).always_included(visited)
                           else
                             {}
                           end
          end
        end

        def extract_from_hash(hash, visited = Set.new)
          return {} if hash.blank?
          return {} if visited.include?(representation_class.name)

          visited = visited.dup.add(representation_class.name)

          if hash.is_a?(Array)
            return hash.each_with_object({}) do |item, result|
              result.deep_merge!(extract_from_hash(item, visited))
            end
          end

          hash.each_with_object({}) do |(key, value), result|
            key = key.to_sym

            if [Capability::Filtering::Constants::OR, Capability::Filtering::Constants::AND].include?(key) && value.is_a?(Array)
              value.each { |item| result.deep_merge!(extract_from_hash(item, visited)) }
              next
            elsif key == Capability::Filtering::Constants::NOT && value.is_a?(Hash)
              result.deep_merge!(extract_from_hash(value, visited))
              next
            end

            association = representation_class.associations[key]
            next unless association

            nested = if value.is_a?(Hash) && association.representation_class.respond_to?(:associations)
                       self.class.new(association.representation_class).from_params(value, visited)
                     else
                       {}
                     end

            result[key] = nested
          end
        end
      end
    end
  end
end
