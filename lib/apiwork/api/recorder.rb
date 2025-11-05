# frozen_string_literal: true

module Apiwork
  module API
    # Records API definitions and builds metadata
    #
    # Coordinates recording by delegating to specialized modules
    class Recorder
      include Recorder::Resources   # Handles resources/resource calls
      include Recorder::Actions      # Handles member/collection actions
      include Recorder::Concerns     # Handles concern definitions
      include Recorder::Inference    # Handles class inference

      attr_reader :metadata, :namespaces_parts

      def initialize(metadata, namespaces_parts)
        @metadata = metadata
        @namespaces_parts = Array(namespaces_parts).map(&:to_sym)
        @resource_stack = []
        @pending_doc = nil
        @current_options = nil
        @in_member_block = false
        @in_collection_block = false
      end

      # Derive namespace string for class names: [:api, :v1] -> 'Api::V1'
      def namespaces_string
        @namespaces_parts.map(&:to_s).map(&:camelize).join('::')
      end

      # Add doc method for documentation blocks
      def doc(&block)
        return unless block

        # Determine level based on context
        level = @resource_stack.empty? ? :api : :resource

        builder = DocumentationBuilder.new(level: level)
        builder.instance_eval(&block)

        if level == :api
          # Store API-level doc immediately
          @metadata.doc = builder.documentation
        else
          # Store resource-level doc as pending
          @pending_doc = builder.documentation
        end
      end
    end
  end
end
