# frozen_string_literal: true

module Apiwork
  module API
    class Info
      # @api public
      # Server definition block.
      #
      # Used within the `server` block in {API::Info}.
      class Server
        def initialize
          @description = nil
          @url = nil
        end

        # @api public
        # The server URL.
        #
        # @param value [String]
        # @return [String, nil]
        #
        # @example
        #   url 'https://api.example.com'
        #   server.url  # => "https://api.example.com"
        def url(value = nil)
          return @url if value.nil?

          @url = value
        end

        # @api public
        # The server description.
        #
        # @param value [String]
        # @return [String, nil]
        #
        # @example
        #   description 'Production'
        #   server.description  # => "Production"
        def description(value = nil)
          return @description if value.nil?

          @description = value
        end
      end
    end
  end
end
