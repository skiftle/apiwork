# frozen_string_literal: true

module Apiwork
  module API
    class InfoBuilder
      # @api public
      # Defines license information for the API.
      #
      # Used within the `license` block in {InfoBuilder}.
      class LicenseBuilder
        attr_reader :data

        def initialize
          @data = {}
        end

        # @api public
        # Sets the license name.
        #
        # @param text [String] the license name (e.g. 'MIT', 'Apache 2.0')
        # @return [void]
        #
        # @example
        #   license do
        #     name 'MIT'
        #   end
        def name(text)
          @data[:name] = text
        end

        # @api public
        # Sets the license URL.
        #
        # @param text [String] the license URL
        # @return [void]
        #
        # @example
        #   license do
        #     url 'https://opensource.org/licenses/MIT'
        #   end
        def url(text)
          @data[:url] = text
        end
      end
    end
  end
end
