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

        def to_h
          {
            email: @email,
            name: @name,
            url: @url,
          }
        end

        # @api public
        # Sets the contact name.
        #
        # @param name [String] the contact name
        # @return [void]
        #
        # @example
        #   contact do
        #     name 'API Support'
        #   end
        def name(name)
          @name = name
        end

        # @api public
        # Sets the contact email.
        #
        # @param email [String] the contact email
        # @return [void]
        #
        # @example
        #   contact do
        #     email 'support@example.com'
        #   end
        def email(email)
          @email = email
        end

        # @api public
        # Sets the contact URL.
        #
        # @param url [String] the contact URL
        # @return [void]
        #
        # @example
        #   contact do
        #     url 'https://example.com/support'
        #   end
        def url(url)
          @url = url
        end
      end
    end
  end
end
