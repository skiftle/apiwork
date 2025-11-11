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

    # Find a single resource by name (returns first match)
    # Searches top-level first, then nested resources
    #
    # @param resource_name [Symbol] Resource name to find
    # @return [Hash, nil] Resource metadata or nil if not found
    def find_resource(resource_name)
      return metadata.resources[resource_name] if metadata.resources[resource_name]

      metadata.resources.each_value do |resource_metadata|
        found = find_resource_recursive(resource_metadata, resource_name)
        return found if found
      end

      nil
    end

    # Find all resources matching a name (including nested)
    # Useful for finding nested resources with same name at different levels
    #
    # @param resource_name [Symbol] Resource name to find
    # @return [Array<Hash>] Array of matching resource metadata hashes
    def find_all_resources(resource_name)
      results = []
      results << metadata.resources[resource_name] if metadata.resources[resource_name]

      metadata.resources.each_value do |resource_metadata|
        find_all_resources_recursive(resource_metadata, resource_name, results)
      end

      results
    end

    # Search for specific data in resources matching a condition
    # Yields each resource metadata to the block for custom matching
    #
    # @yield [resource_metadata] Block that returns truthy value for matches
    # @return [Object, nil] First truthy result from block or nil
    #
    # @example Find HTTP method for an action
    #   searcher.search_resources do |resource_metadata|
    #     resource_metadata[:members]&.dig(:publish, :method) if matches_contract?(resource_metadata)
    #   end
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
      if resource_metadata[:resources]&.key?(resource_name)
        results << resource_metadata[:resources][resource_name]
      end

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
