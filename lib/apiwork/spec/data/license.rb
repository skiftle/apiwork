# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps API license information.
      #
      # @example
      #   license = api.info.license
      #   license.name  # => "MIT"
      #   license.url   # => "https://opensource.org/licenses/MIT"
      class License
        def initialize(data)
          @data = data || {}
        end

        # @return [String, nil] license name
        def name
          @data[:name]
        end

        # @return [String, nil] license URL
        def url
          @data[:url]
        end
      end
    end
  end
end
