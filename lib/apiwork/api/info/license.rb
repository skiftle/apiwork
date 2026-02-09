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
        # @param value [String, nil] (nil)
        # @return [String, nil]
        #
        # @example
        #   name 'MIT'
        #   license.name  # => "MIT"
        def name(value = nil)
          return @name if value.nil?

          @name = value
        end

        # @api public
        # The license URL.
        #
        # @param value [String, nil] (nil)
        # @return [String, nil]
        #
        # @example
        #   url 'https://opensource.org/licenses/MIT'
        #   license.url  # => "https://opensource.org/licenses/MIT"
        def url(value = nil)
          return @url if value.nil?

          @url = value
        end
      end
    end
  end
end
