# frozen_string_literal: true

module Apiwork
  module API
    # Records API definitions and builds metadata
    #
    # Coordinates recording by delegating to specialized modules
    class Recorder
      include Recorder::Resources # Handles resources/resource calls
      include Recorder::Actions      # Handles member/collection actions
      include Recorder::Concerns     # Handles concern definitions
      include Recorder::Inference    # Handles class inference

      attr_reader :metadata

      def initialize(metadata, namespaces_parts)
        @metadata = metadata
        @namespaces = namespaces_parts
        @resource_stack = []
        @pending_info = nil
        @current_options = nil
        @in_member_block = false
        @in_collection_block = false
      end

      # Delegate to metadata
      def namespaces_string
        metadata.namespaces_string
      end

      # Add info method for info blocks
      def info(&block)
        return unless block

        # Determine level based on context
        level = @resource_stack.empty? ? :api : :resource

        builder = Info::Builder.new(level: level)
        builder.instance_eval(&block)

        if level == :api
          # Store API-level info immediately
          @metadata.info = builder.info
        else
          # Store resource-level info as pending
          @pending_info = builder.info
        end
      end
    end
  end
end
