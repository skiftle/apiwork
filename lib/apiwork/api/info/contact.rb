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
        # @param name [String]
        # @return [String, nil]
        #
        # @example
        #   name 'API Support'
        #   contact.name  # => "API Support"
        def name(name = nil)
          return @name if name.nil?

          @name = name
        end

        # @api public
        # The contact email.
        #
        # @param email [String]
        # @return [String, nil]
        #
        # @example
        #   email 'support@example.com'
        #   contact.email  # => "support@example.com"
        def email(email = nil)
          return @email if email.nil?

          @email = email
        end

        # @api public
        # The contact URL.
        #
        # @param url [String]
        # @return [String, nil]
        #
        # @example
        #   url 'https://example.com/support'
        #   contact.url  # => "https://example.com/support"
        def url(url = nil)
          return @url if url.nil?

          @url = url
        end
      end
    end
  end
end
