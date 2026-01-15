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
        #   license.name  # => "MIT"
        #   license.url   # => "https://opensource.org/licenses/MIT"
        class License
          def initialize(dump)
            @dump = dump
          end

          # @api public
          # @return [String, nil] license name
          def name
            @dump[:name]
          end

          # @api public
          # @return [String, nil] license URL
          def url
            @dump[:url]
          end

          # @api public
          # @return [Hash] structured representation
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
