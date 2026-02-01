# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module API
        class Context
          def initialize(api_class)
            @representation_registry = api_class.representation_registry
            @root_resource = api_class.root_resource
          end

          def has_index_actions?
            @root_resource.has_index_actions?
          end

          delegate :filter_types,
                   :filterable?,
                   :nullable_filter_types,
                   :sortable?,
                   to: :@representation_registry

          def configured(capability, key)
            @representation_registry.options_for(capability, key)
          end
        end
      end
    end
  end
end
