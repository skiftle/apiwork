# frozen_string_literal: true

module Apiwork
  module API
    # Records API definitions and builds metadata
    #
    # Coordinates recording by delegating to specialized modules
    class Recorder
      include Recorder::Resources    # Handles resources/resource calls
      include Recorder::Actions      # Handles member/collection actions
      include Recorder::Concerns     # Handles concern definitions
      include Recorder::Inference    # Handles class inference
      include Recorder::Description  # Handles description DSL

      attr_reader :metadata

      def initialize(metadata, namespaces_parts)
        @metadata = metadata
        @namespaces = namespaces_parts
        @resource_stack = []
        @current_options = nil
        @in_member_block = false
        @in_collection_block = false
        @pending_metadata = {}
      end

      # Delegate to metadata
      def namespaces_string
        metadata.namespaces_string
      end
    end
  end
end
