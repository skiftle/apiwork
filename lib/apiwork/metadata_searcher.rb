# frozen_string_literal: true

module Apiwork
  # Service for searching and navigating API metadata structures
  #
  # Provides unified methods for finding resources in nested metadata trees,
  # eliminating duplicate recursive search implementations across the codebase.
  class MetadataSearcher
    attr_reader :metadata

    def initialize(metadata)
      @metadata = metadata
    end

    def find_resource(resource_name)
      return metadata.resources[resource_name] if metadata.resources[resource_name]

      metadata.resources.each_value do |resource_metadata|
        found = find_resource_recursive(resource_metadata, resource_name)
        return found if found
      end

      nil
    end

    def find_all_resources(resource_name)
      results = []
      results << metadata.resources[resource_name] if metadata.resources[resource_name]

      metadata.resources.each_value do |resource_metadata|
        find_all_resources_recursive(resource_metadata, resource_name, results)
      end

      results
    end

    def search_resources(&block)
      metadata.resources.each_value do |resource_metadata|
        result = search_in_resource_tree(resource_metadata, &block)
        return result if result
      end

      nil
    end

    private

    # Recursively search for single resource in nested tree
    def find_resource_recursive(resource_metadata, resource_name)
      return resource_metadata[:resources][resource_name] if resource_metadata[:resources]&.key?(resource_name)

      resource_metadata[:resources]&.each_value do |nested_metadata|
        found = find_resource_recursive(nested_metadata, resource_name)
        return found if found
      end

      nil
    end

    # Recursively collect all resources matching name
    def find_all_resources_recursive(resource_metadata, resource_name, results)
      results << resource_metadata[:resources][resource_name] if resource_metadata[:resources]&.key?(resource_name)

      resource_metadata[:resources]&.each_value do |nested_metadata|
        find_all_resources_recursive(nested_metadata, resource_name, results)
      end

      results
    end

    # Recursively search resource tree with custom block condition
    def search_in_resource_tree(resource_metadata, &block)
      # Check current resource
      result = yield(resource_metadata)
      return result if result

      # Search nested resources
      resource_metadata[:resources]&.each_value do |nested_metadata|
        result = search_in_resource_tree(nested_metadata, &block)
        return result if result
      end

      nil
    end
  end
end
