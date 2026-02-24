# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Collection
        # @api public
        # Base class for collection response wrappers.
        #
        # Collection wrappers structure responses for index actions that return
        # multiple records. Extend this class to customize how collections are
        # wrapped in your API responses.
        #
        # @example Custom collection wrapper
        #   class MyCollectionWrapper < Wrapper::Collection::Base
        #     shape do
        #       array(root_key.plural.to_sym) do |array|
        #         array.reference(data_type)
        #       end
        #       object?(:meta)
        #       metadata_type_names.each { |type_name| merge(type_name) }
        #     end
        #
        #     def wrap
        #       { root_key.plural.to_sym => data, meta: meta.presence, **metadata }.compact
        #     end
        #   end
        class Base < Wrapper::Base
          self.wrapper_type = :collection

          # @!attribute [r] meta
          #   @api public
          #   The meta for this wrapper.
          #
          #   @return [Hash]
          # @!attribute [r] metadata
          #   @api public
          #   The metadata for this wrapper.
          #
          #   @return [Hash]
          # @!attribute [r] root_key
          #   @api public
          #   The root key for this wrapper.
          #
          #   @return [RootKey]
          attr_reader :meta,
                      :metadata,
                      :root_key

          def initialize(data, metadata, root_key, meta)
            super(data)
            @metadata = metadata
            @root_key = root_key
            @meta = meta
          end
        end
      end
    end
  end
end
