# frozen_string_literal: true

module Apiwork
  module Controller
    # Main controller concern - Facade that includes all Apiwork controller functionality
    #
    # This concern provides a unified interface for:
    # - Request validation (Validation) - provides action_input
    # - Resource serialization and response building (Serialization) - provides action_output
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
    #       client = Client.create(action_input[:client])
    #       respond_with(client)
    #     end
    #   end
    #
    module Concern
      extend ActiveSupport::Concern

      included do
        # Disable Rails parameter wrapping
        # Apiwork contracts define explicit parameter structures
        wrap_parameters false
      end

      include Validation
      include Serialization
      include ActionMetadata
    end
  end
end
