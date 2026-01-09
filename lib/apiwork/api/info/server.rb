# frozen_string_literal: true

module Apiwork
  module API
    class Info
      # @api public
      # Defines server information for the API.
      #
      # Used within the `server` block in {API::Info}.
      class Server
        def initialize
          @description = nil
          @url = nil
        end

        def to_h
          {
            description: @description,
            url: @url,
          }
        end

        # @api public
        # Sets the server URL.
        #
        # @param url [String] the server URL
        # @return [void]
        #
        # @example
        #   server do
        #     url 'https://api.example.com'
        #   end
        def url(url)
          @url = url
        end

        # @api public
        # Sets the server description.
        #
        # @param description [String] the server description
        # @return [void]
        #
        # @example
        #   server do
        #     description 'Production'
        #   end
        def description(description)
          @description = description
        end
      end
    end
  end
end
