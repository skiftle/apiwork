# frozen_string_literal: true

module Apiwork
  module Errors
    class Handler
      class << self
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
