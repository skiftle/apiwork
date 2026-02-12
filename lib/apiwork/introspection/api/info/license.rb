# frozen_string_literal: true

module Apiwork
  module Introspection
    class API
      class Info
        # @api public
        # Wraps API license information.
        #
        # @example
        #   license = api.info.license
        #   license.name # => "MIT"
        #   license.url # => "https://opensource.org/licenses/MIT"
        class License
          def initialize(dump)
            @dump = dump
          end

          # @api public
          # The license name.
          #
          # @return [String, nil]
          def name
            @dump[:name]
          end

          # @api public
          # The license URL.
          #
          # @return [String, nil]
          def url
            @dump[:url]
          end

          # @api public
          # Converts this license to a hash.
          #
          # @return [Hash]
          def to_h
            {
              name: name,
              url: url,
            }
          end
        end
      end
    end
  end
end
