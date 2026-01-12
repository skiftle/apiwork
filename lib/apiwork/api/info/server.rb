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

        # @api public
        # Sets or gets the server URL.
        #
        # @param url [String] the server URL
        # @return [String, void]
        #
        # @example
        #   server do
        #     url 'https://api.example.com'
        #   end
        def url(url = nil)
          return @url if url.nil?

          @url = url
        end

        # @api public
        # Sets or gets the server description.
        #
        # @param description [String] the server description
        # @return [String, void]
        #
        # @example
        #   server do
        #     description 'Production'
        #   end
        def description(description = nil)
          return @description if description.nil?

          @description = description
        end
      end
    end
  end
end
