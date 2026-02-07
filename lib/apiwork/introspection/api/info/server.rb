# frozen_string_literal: true

module Apiwork
  module Introspection
    class API
      class Info
        # @api public
        # Wraps API server information.
        #
        # @example
        #   api.info.servers.each do |server|
        #     puts server.url          # => "https://api.example.com"
        #     puts server.description  # => "Production server"
        #   end
        class Server
          def initialize(dump)
            @dump = dump
          end

          # @api public
          # The server URL.
          #
          # @return [String, nil]
          def url
            @dump[:url]
          end

          # @api public
          # The server description.
          #
          # @return [String, nil]
          def description
            @dump[:description]
          end

          # @api public
          # Converts this server to a hash.
          #
          # @return [Hash]
          def to_h
            {
              description: description,
              url: url,
            }
          end
        end
      end
    end
  end
end
