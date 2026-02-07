# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        # @api public
        # Scope for capability contract builders.
        #
        # Provides access to the representation and actions for this contract.
        # Use this to query contract-specific state when building types.
        class Scope
          # @api public
          # The actions for this scope.
          #
          # @return [Hash{Symbol => Resource::Action}]
          attr_reader :actions

          attr_reader :representation_class

          def initialize(representation_class, actions)
            @representation_class = representation_class
            @actions = actions
          end

          # @api public
          # The collection actions for this scope.
          #
          # @return [Hash{Symbol => Resource::Action}]
          def collection_actions
            @collection_actions ||= actions.select { |_name, action| action.collection? }
          end

          # @api public
          # The member actions for this scope.
          #
          # @return [Hash{Symbol => Resource::Action}]
          def member_actions
            @member_actions ||= actions.select { |_name, action| action.member? }
          end

          # @api public
          # The CRUD actions for this scope.
          #
          # @return [Hash{Symbol => Resource::Action}]
          def crud_actions
            @crud_actions ||= actions.select { |_name, action| action.crud? }
          end

          # @api public
          # Whether an action exists.
          #
          # @param name [Symbol] the action name
          # @return [Boolean]
          def action?(name)
            actions.key?(name.to_sym)
          end

          # @api public
          # The filterable attributes for this scope.
          #
          # @return [Array<Representation::Attribute>]
          def filterable_attributes
            @filterable_attributes ||= attributes.values.select(&:filterable?)
          end

          # @api public
          # The sortable attributes for this scope.
          #
          # @return [Array<Representation::Attribute>]
          def sortable_attributes
            @sortable_attributes ||= attributes.values.select(&:sortable?)
          end

          # @api public
          # The writable attributes for this scope.
          #
          # @return [Array<Representation::Attribute>]
          def writable_attributes
            @writable_attributes ||= attributes.values.select(&:writable?)
          end

          # @!method associations
          #   @api public
          #   The associations for this scope.
          #
          #   @return [Hash{Symbol => Representation::Association}]
          #
          # @!method attributes
          #   @api public
          #   The attributes for this scope.
          #
          #   @return [Hash{Symbol => Representation::Attribute}]
          #
          # @!method root_key
          #   @api public
          #   The root key for this scope.
          #
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
