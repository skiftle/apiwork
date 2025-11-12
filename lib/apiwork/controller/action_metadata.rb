# frozen_string_literal: true

module Apiwork
  module Controller
    # Provides helpers for accessing routing DSL metadata from controllers
    #
    # This allows controllers to look up resource_class_name, contract_class_name,
    # and controller_class_name that were specified in the routing DSL for the
    # current action.
    #
    module ActionMetadata
      extend ActiveSupport::Concern

      # Find metadata for the current action from routing DSL
      #
      # @return [Hash, nil] Metadata hash with :resource_class_name, :contract_class_name, etc.
      #
      # @example
      #   # In a controller action:
      #   metadata = find_action_metadata
      #   if metadata
      #     resource_class_name = metadata[:resource_class_name]
      #     contract_class_name = metadata[:contract_class_name]
      #   end
      #
      def find_action_metadata
        # Determine API path from controller namespace
        # e.g., Api::V1::ArticlesController -> '/api/v1'
        namespace_parts = self.class.name.deconstantize.split('::')
        return nil if namespace_parts.empty?

        api_path = "/#{namespace_parts.map(&:underscore).join('/')}"

        # Find API class
        api_class = Apiwork::API.find(api_path)
        return nil unless api_class&.metadata

        # Extract resource name from controller
        # e.g., Api::V1::ArticlesController -> :articles
        resource_name = controller_name.to_sym

        # Find resource metadata
        resource_metadata = find_resource_in_metadata(api_class.metadata, resource_name)
        return nil unless resource_metadata

        # Check if current action is a standard REST action
        action_name_sym = action_name.to_sym
        if resource_metadata[:actions]&.include?(action_name_sym)
          # Standard action - return resource-level metadata
          {
            schema_class: resource_metadata[:schema_class],
            contract_class_name: resource_metadata[:contract_class_name],
            controller_class_name: resource_metadata[:controller_class_name]
          }
        elsif resource_metadata[:members]&.key?(action_name_sym)
          # Check member actions
          member_metadata = resource_metadata[:members][action_name_sym]
          {
            schema_class: member_metadata[:schema_class] || resource_metadata[:schema_class],
            contract_class_name: member_metadata[:contract_class_name] || resource_metadata[:contract_class_name],
            controller_class_name: resource_metadata[:controller_class_name]
          }
          # Check collection actions
        elsif resource_metadata[:collections]&.key?(action_name_sym)
          collection_metadata = resource_metadata[:collections][action_name_sym]
          {
            schema_class: collection_metadata[:schema_class] || resource_metadata[:schema_class],
            contract_class_name: collection_metadata[:contract_class_name] || resource_metadata[:contract_class_name],
            controller_class_name: resource_metadata[:controller_class_name]
          }
        end
      end

      private

      # Recursively find resource in metadata tree
      # For nested resources with custom actions, we need to find the resource
      # that actually has the action we're looking for
      def find_resource_in_metadata(metadata, resource_name)
        action_name_sym = action_name.to_sym
        searcher = Apiwork::MetadataSearcher.new(metadata)

        # Collect all resources with this name (top-level and nested)
        candidates = searcher.find_all_resources(resource_name)

        # If we have multiple candidates, prefer the one that has the current action
        # This handles nested resources with custom member/collection actions
        if candidates.many?
          # Check which candidate has this action defined
          candidate_with_action = candidates.find do |candidate|
            candidate[:actions]&.include?(action_name_sym) ||
              candidate[:members]&.key?(action_name_sym) ||
              candidate[:collections]&.key?(action_name_sym)
          end
          return candidate_with_action if candidate_with_action
        end

        # Return first candidate (or nil if no candidates)
        candidates.first
      end
    end
  end
end
