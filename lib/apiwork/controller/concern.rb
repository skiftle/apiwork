# frozen_string_literal: true

require_relative 'validation'
require_relative 'action_params'
require_relative 'serialization'
require_relative 'action_metadata'

module Apiwork
  module Controller
    # Main controller concern - Facade that includes all Apiwork controller functionality
    #
    # This concern provides a unified interface for:
    # - Request validation (Validation)
    # - Action-specific parameter access (ActionParams)
    # - Resource serialization and response building (Serialization)
    # - Automatic query building for index actions (built into Serialization)
    #
    # @example Basic usage
    #   class ClientsController < ApplicationController
    #     include Apiwork::Controller::Concern
    #
    #     def index
    #       respond_with Client.all  # Query happens automatically
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

      included do
        # Disable Rails parameter wrapping
        # Apiwork contracts define explicit parameter structures
        # and handle wrapping through action_params helper
        wrap_parameters false
      end

      include Validation
      include Serialization
      include ActionParams
      include ActionMetadata
    end
  end
end
