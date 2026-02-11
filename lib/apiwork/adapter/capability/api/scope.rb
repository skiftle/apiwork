# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module API
        # @api public
        # Aggregated scope for capability API builders.
        #
        # Provides access to data collected across all representations in the API.
        # Use this to query API-wide state when building shared types.
        class Scope
          def initialize(api_class)
            @representation_registry = api_class.representation_registry
            @root_resource = api_class.root_resource
          end

          # @!method has_index_actions?
          #   @api public
          #   Returns whether any resource has index actions.
          #   @return [Boolean]
          delegate :has_index_actions?, to: :@root_resource

          # @!method filter_types
          #   @api public
          #   Returns all filterable types across representations.
          #   @return [Set<Symbol>]
          #
          # @!method nullable_filter_types
          #   @api public
          #   Returns filterable types that can be null.
          #   @return [Set<Symbol>]
          #
          # @!method filterable?
          #   @api public
          #   Returns whether any representation has filterable attributes.
          #   @return [Boolean]
          #
          # @!method sortable?
          #   @api public
          #   Returns whether any representation has sortable attributes.
          #   @return [Boolean]
          delegate :filter_types,
                   :filterable?,
                   :nullable_filter_types,
                   :sortable?,
                   to: :@representation_registry

          # @api public
          # The configured values for a capability.
          #
          # @param capability [Symbol]
          #   The capability name.
          # @param key [Symbol]
          #   The configuration key.
          # @return [Set]
          def configured(capability, key)
            @representation_registry.options_for(capability, key)
          end
        end
      end
    end
  end
end
