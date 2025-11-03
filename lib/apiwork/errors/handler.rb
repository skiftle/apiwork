# frozen_string_literal: true

module Apiwork
  module Errors
    # Centralized error handling service
    #
    # Handles errors according to configured error_handling_mode:
    # - :raise - Re-raise the error (strict mode)
    # - :log - Log the error and return nil (development/debugging)
    # - :silent - Silently ignore the error (production tolerance)
    #
    # @example Handle a filter error
    #   Errors::Handler.handle(error, context: { field: :status, operator: :invalid })
    #
    class Handler
      class << self
        # Handle an error according to configured mode
        #
        # @param error [Exception] The error to handle
        # @param context [Hash] Additional context for logging
        # @return [nil] Returns nil in :log or :silent modes
        # @raise [Exception] Re-raises error in :raise mode
        def handle(error, context: {})
          case Apiwork.configuration.error_handling_mode
          when :raise
            raise error
          when :log
            log_error(error, context)
            nil
          when :silent
            nil
          else
            # Default to :silent for unknown modes
            nil
          end
        end

        private

        # Log error with context
        #
        # @param error [Exception] The error to log
        # @param context [Hash] Additional context information
        def log_error(error, context)
          return unless defined?(::Rails)

          ::Rails.logger.warn("Apiwork Error: #{error.class} - #{error.message}")
          ::Rails.logger.debug("Context: #{context.inspect}") if context.present?
          ::Rails.logger.debug(error.backtrace.first(5).join("\n")) if error.backtrace
        end
      end
    end
  end
end
