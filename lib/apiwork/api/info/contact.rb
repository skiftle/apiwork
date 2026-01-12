# frozen_string_literal: true

module Apiwork
  module API
    class Info
      # @api public
      # Defines contact information for the API.
      #
      # Used within the `contact` block in {API::Info}.
      class Contact
        def initialize
          @email = nil
          @name = nil
          @url = nil
        end

        # @api public
        # Sets or gets the contact name.
        #
        # @param name [String] the contact name
        # @return [String, void]
        #
        # @example
        #   contact do
        #     name 'API Support'
        #   end
        def name(name = nil)
          return @name if name.nil?

          @name = name
        end

        # @api public
        # Sets or gets the contact email.
        #
        # @param email [String] the contact email
        # @return [String, void]
        #
        # @example
        #   contact do
        #     email 'support@example.com'
        #   end
        def email(email = nil)
          return @email if email.nil?

          @email = email
        end

        # @api public
        # Sets or gets the contact URL.
        #
        # @param url [String] the contact URL
        # @return [String, void]
        #
        # @example
        #   contact do
        #     url 'https://example.com/support'
        #   end
        def url(url = nil)
          return @url if url.nil?

          @url = url
        end
      end
    end
  end
end
