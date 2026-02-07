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
          def initialize(dump)
            @dump = dump
          end

          # @api public
          # The contact name.
          #
          # @return [String, nil]
          def name
            @dump[:name]
          end

          # @api public
          # The contact email.
          #
          # @return [String, nil]
          def email
            @dump[:email]
          end

          # @api public
          # The contact URL.
          #
          # @return [String, nil]
          def url
            @dump[:url]
          end

          # @api public
          # Converts this contact to a hash.
          #
          # @return [Hash]
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
