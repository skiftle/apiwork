# frozen_string_literal: true

module Apiwork
  # API definition system
  #
  # Define APIs using a clean DSL with path as the source of truth:
  #
  # @example Define an API in config/apis/v1.rb
  #   Apiwork::API.draw '/api/v1' do
  #     schemas :openapi, :transport, :zod
  #
  #     doc do
  #       title 'My API'
  #       version '1.0.0'
  #     end
  #
  #     resources :accounts do
  #       resources :clients
  #     end
  #   end
  #
  # @example Define a root-level API
  #   Apiwork::API.draw '/' do
  #     resources :health
  #   end
  #
  # @example Find an API
  #   api = Apiwork::API.find('/api/v1')
  #   api.metadata.resources
  #
  # @example List all APIs
  #   Apiwork::API.all
  module API
    # Draw a new API with the given path
    #
    # Path is the source of truth - it determines:
    # - Mount path (where routes are exposed)
    # - Namespaces (Ruby module structure for controllers)
    # - Identifier (for lookups and generation)
    #
    # @param path [String] The mount path (e.g., '/api/v1', '/', '/admin')
    # @param block [Proc] The API definition block
    # @return [Class] The generated API definition class
    #
    # @example
    #   API.draw '/api/v1' do
    #     resources :accounts
    #   end
    #   # → Mounts at /api/v1
    #   # → Controllers in Api::V1
    #   # → Identifier: 'api/v1'
    def self.draw(path, &block)
      return unless block

      definition_class = Class.new(Base)
      definition_class.configure_from_path(path)
      definition_class.class_eval(&block)
      definition_class
    end

    # Find an API by its path
    #
    # @param path [String] The path to look up (e.g., '/api/v1', 'api/v1', '/')
    # @return [Class, nil] The API definition class or nil
    def self.find(path)
      Registry.find(path)
    end

    # Get all registered APIs
    #
    # @return [Array<Class>] All registered API definition classes
    def self.all
      Registry.all_classes
    end
  end
end
