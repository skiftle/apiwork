# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      include Recorder::Resource     # Handles resources/resource calls
      include Recorder::Action       # Handles member/collection actions
      include Recorder::Concern      # Handles concern definitions
      include Recorder::Inference    # Handles class inference

      attr_reader :structure

      def initialize(structure, namespaces)
        @structure = structure
        @namespaces = namespaces
        @resource_stack = []
        @current_options = nil
        @in_member_block = false
        @in_collection_block = false
        @pending_metadata = {}
        @concerns = {}
      end
    end
  end
end
