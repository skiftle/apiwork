# frozen_string_literal: true

module Apiwork
  module Spec
    class Data
      # @api public
      # Wraps API server information.
      #
      # @example
      #   data.info.servers.each do |server|
      #     puts server.url          # => "https://api.example.com"
      #     puts server.description  # => "Production server"
      #   end
      class Server
        def initialize(data)
          @data = data || {}
        end

        # @api public
        # @return [String, nil] server URL
        def url
          @data[:url]
        end

        # @api public
        # @return [String, nil] server description
        def description
          @data[:description]
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          { description: description, url: url }
        end
      end
    end
  end
end
