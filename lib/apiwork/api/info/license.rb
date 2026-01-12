# frozen_string_literal: true

module Apiwork
  module API
    class Info
      # @api public
      # Defines license information for the API.
      #
      # Used within the `license` block in {API::Info}.
      class License
        def initialize
          @name = nil
          @url = nil
        end

        # @api public
        # Sets or gets the license name.
        #
        # @param name [String] the license name (e.g. 'MIT', 'Apache 2.0')
        # @return [String, void]
        #
        # @example
        #   license do
        #     name 'MIT'
        #   end
        def name(name = nil)
          return @name if name.nil?

          @name = name
        end

        # @api public
        # Sets or gets the license URL.
        #
        # @param url [String] the license URL
        # @return [String, void]
        #
        # @example
        #   license do
        #     url 'https://opensource.org/licenses/MIT'
        #   end
        def url(url = nil)
          return @url if url.nil?

          @url = url
        end
      end
    end
  end
end
