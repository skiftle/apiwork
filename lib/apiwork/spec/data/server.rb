# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps API server information.
      #
      # @example
      #   api.info.servers.each do |server|
      #     puts server.url          # => "https://api.example.com"
      #     puts server.description  # => "Production server"
      #   end
      class Server
        def initialize(data)
          @data = data || {}
        end

        # @return [String, nil] server URL
        def url
          @data[:url]
        end

        # @return [String, nil] server description
        def description
          @data[:description]
        end
      end
    end
  end
end
