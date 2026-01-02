# frozen_string_literal: true

module Apiwork
  module Introspection
    class API
      class Info
        # @api public
        # Wraps API contact information.
        #
        # @example
        #   contact = api.info.contact
        #   contact.name   # => "API Support"
        #   contact.email  # => "support@example.com"
        #   contact.url    # => "https://example.com/support"
        class Contact
          def initialize(data)
            @data = data || {}
          end

          # @api public
          # @return [String, nil] contact name
          def name
            @data[:name]
          end

          # @api public
          # @return [String, nil] contact email
          def email
            @data[:email]
          end

          # @api public
          # @return [String, nil] contact URL
          def url
            @data[:url]
          end

          # @api public
          # @return [Hash] structured representation
          def to_h
            {
              email: email,
              name: name,
              url: url,
            }
          end
        end
      end
    end
  end
end
