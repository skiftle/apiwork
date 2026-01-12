# frozen_string_literal: true

module Apiwork
  module API
    class Info
      # @api public
      # License information block.
      #
      # Used within the `license` block in {API::Info}.
      class License
        def initialize
          @name = nil
          @url = nil
        end

        # @api public
        # The license name.
        #
        # @param name [String] e.g. 'MIT', 'Apache 2.0'
        # @return [String, nil]
        #
        # @example
        #   name 'MIT'
        #   license.name  # => "MIT"
        def name(name = nil)
          return @name if name.nil?

          @name = name
        end

        # @api public
        # The license URL.
        #
        # @param url [String]
        # @return [String, nil]
        #
        # @example
        #   url 'https://opensource.org/licenses/MIT'
        #   license.url  # => "https://opensource.org/licenses/MIT"
        def url(url = nil)
          return @url if url.nil?

          @url = url
        end
      end
    end
  end
end
