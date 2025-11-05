# frozen_string_literal: true

require_relative 'validation'
require_relative 'query'
require_relative 'action_params'
require_relative 'serialization'
require_relative 'action_metadata'

module Apiwork
  module Controller
    # Main controller concern - Facade that includes all Apiwork controller functionality
    #
    # This concern provides a unified interface for:
    # - Request validation (Validation)
    # - Query building with filter/sort/pagination (Query)
    # - Action-specific parameter access (ActionParams)
    # - Resource serialization and response building (Serialization)
    #
    # @example Basic usage
    #   class ClientsController < ApplicationController
    #     include Apiwork::Controller::Concern
    #
    #     def index
    #       clients = query(Client.all)
    #       respond_with(clients)
    #     end
    #
    #     def create
    #       client = Client.new(action_params)
    #       client.save
    #       respond_with(client)
    #     end
    #   end
    #
    module Concern
      extend ActiveSupport::Concern

      include Validation
      include Serialization
      include Query
      include ActionParams
      include ActionMetadata
    end
  end
end
