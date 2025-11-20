# frozen_string_literal: true

module Apiwork
  module API
    # Records API definitions and builds metadata
    #
    # Coordinates recording by delegating to specialized modules
    class Recorder
      include Recorder::Resource     # Handles resources/resource calls
      include Recorder::Action       # Handles member/collection actions
      include Recorder::Concern      # Handles concern definitions
      include Recorder::Inference    # Handles class inference
      include Recorder::Description  # Handles description DSL

      attr_reader :metadata

      def initialize(metadata, namespaces)
        @metadata = metadata
        @namespaces = namespaces
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
