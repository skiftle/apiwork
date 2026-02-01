# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        class Context
          attr_reader :actions, :representation_class

          def initialize(representation_class, actions)
            @representation_class = representation_class
            @actions = actions
          end

          def collection_actions
            @collection_actions ||= actions.select { |_name, action| action.collection? }
          end

          def member_actions
            @member_actions ||= actions.select { |_name, action| action.member? }
          end

          def crud_actions
            @crud_actions ||= actions.select { |_name, action| action.crud? }
          end

          def action?(name)
            actions.key?(name.to_sym)
          end

          def filterable_attributes
            @filterable_attributes ||= attributes.values.select(&:filterable?)
          end

          def sortable_attributes
            @sortable_attributes ||= attributes.values.select(&:sortable?)
          end

          def writable_attributes
            @writable_attributes ||= attributes.values.select(&:writable?)
          end

          delegate :adapter_config,
                   :associations,
                   :attributes,
                   :root_key,
                   to: :representation_class
        end
      end
    end
  end
end
