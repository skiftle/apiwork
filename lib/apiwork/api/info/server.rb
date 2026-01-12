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
        # @param url [String]
        # @return [String, nil]
        #
        # @example
        #   url 'https://api.example.com'
        #   server.url  # => "https://api.example.com"
        def url(url = nil)
          return @url if url.nil?

          @url = url
        end

        # @api public
        # The server description.
        #
        # @param description [String]
        # @return [String, nil]
        #
        # @example
        #   description 'Production'
        #   server.description  # => "Production"
        def description(description = nil)
          return @description if description.nil?

          @description = description
        end
      end
    end
  end
end
