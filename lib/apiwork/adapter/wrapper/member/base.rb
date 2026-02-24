# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Member
        # @api public
        # Base class for member response wrappers.
        #
        # Member wrappers structure responses for show, create, and update actions
        # that return a single record. Extend this class to customize how individual
        # resources are wrapped in your API responses.
        #
        # @example Custom member wrapper
        #   class MyMemberWrapper < Wrapper::Member::Base
        #     shape do
        #       reference(root_key.singular.to_sym, to: data_type)
        #       object?(:meta)
        #       metadata_type_names.each { |type_name| merge(type_name) }
        #     end
        #
        #     def wrap
        #       { root_key.singular.to_sym => data, meta: meta.presence, **metadata }.compact
        #     end
        #   end
        class Base < Wrapper::Base
          self.wrapper_type = :member

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
