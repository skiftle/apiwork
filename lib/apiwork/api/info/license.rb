# frozen_string_literal: true

module Apiwork
  module API
    class Info
      # @api public
      # Defines license information for the API.
      #
      # Used within the `license` block in {API::Info}.
      class License
        attr_reader :data

        def initialize
          @data = {}
        end

        # @api public
        # Sets the license name.
        #
        # @param name [String] the license name (e.g. 'MIT', 'Apache 2.0')
        # @return [void]
        #
        # @example
        #   license do
        #     name 'MIT'
        #   end
        def name(name)
          @data[:name] = name
        end

        # @api public
        # Sets the license URL.
        #
        # @param url [String] the license URL
        # @return [void]
        #
        # @example
        #   license do
        #     url 'https://opensource.org/licenses/MIT'
        #   end
        def url(url)
          @data[:url] = url
        end
      end
    end
  end
end
