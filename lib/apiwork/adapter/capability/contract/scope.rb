# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        # @api public
        # Scope for capability contract builders.
        #
        # Provides access to the representation and actions linked to this contract.
        # Use this to query contract-specific state when building types.
        class Scope
          # @api public
          # @return [Hash{Symbol => Resource::Action}] actions linked to this contract
          attr_reader :actions

          attr_reader :representation_class

          def initialize(representation_class, actions)
            @representation_class = representation_class
            @actions = actions
          end

          # @api public
          # Returns actions that operate on collections.
          #
          # @return [Hash{Symbol => Resource::Action}]
          def collection_actions
            @collection_actions ||= actions.select { |_name, action| action.collection? }
          end

          # @api public
          # Returns actions that operate on a single resource.
          #
          # @return [Hash{Symbol => Resource::Action}]
          def member_actions
            @member_actions ||= actions.select { |_name, action| action.member? }
          end

          # @api public
          # Returns CRUD actions only.
          #
          # @return [Hash{Symbol => Resource::Action}]
          def crud_actions
            @crud_actions ||= actions.select { |_name, action| action.crud? }
          end

          # @api public
          # Returns whether an action exists.
          #
          # @param name [Symbol] the action name
          # @return [Boolean]
          def action?(name)
            actions.key?(name.to_sym)
          end

          # @api public
          # Returns attributes that are filterable.
          #
          # @return [Array<Representation::Attribute>]
          def filterable_attributes
            @filterable_attributes ||= attributes.values.select(&:filterable?)
          end

          # @api public
          # Returns attributes that are sortable.
          #
          # @return [Array<Representation::Attribute>]
          def sortable_attributes
            @sortable_attributes ||= attributes.values.select(&:sortable?)
          end

          # @api public
          # Returns attributes that are writable.
          #
          # @return [Array<Representation::Attribute>]
          def writable_attributes
            @writable_attributes ||= attributes.values.select(&:writable?)
          end

          # @!method associations
          #   @api public
          #   @return [Hash{Symbol => Representation::Association}]
          #
          # @!method attributes
          #   @api public
          #   @return [Hash{Symbol => Representation::Attribute}]
          #
          # @!method root_key
          #   @api public
          #   @return [Representation::RootKey]
          delegate :associations,
                   :attributes,
                   :root_key,
                   to: :representation_class

          delegate :adapter_config, to: :representation_class
        end
      end
    end
  end
end
