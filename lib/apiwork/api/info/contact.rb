# frozen_string_literal: true

module Apiwork
  module API
    class Info
      # @api public
      # Contact information block.
      #
      # Used within the `contact` block in {API::Info}.
      class Contact
        def initialize
          @email = nil
          @name = nil
          @url = nil
        end

        # @api public
        # The contact name.
        #
        # @param value [String, nil] (nil)
        #   The name.
        # @return [String, nil]
        #
        # @example
        #   name 'API Support'
        #   contact.name  # => "API Support"
        def name(value = nil)
          return @name if value.nil?

          @name = value
        end

        # @api public
        # The contact email.
        #
        # @param value [String, nil] (nil)
        #   The email.
        # @return [String, nil]
        #
        # @example
        #   email 'support@example.com'
        #   contact.email  # => "support@example.com"
        def email(value = nil)
          return @email if value.nil?

          @email = value
        end

        # @api public
        # The contact URL.
        #
        # @param value [String, nil] (nil)
        #   The URL.
        # @return [String, nil]
        #
        # @example
        #   url 'https://example.com/support'
        #   contact.url  # => "https://example.com/support"
        def url(value = nil)
          return @url if value.nil?

          @url = value
        end
      end
    end
  end
end
