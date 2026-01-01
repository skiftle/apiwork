# frozen_string_literal: true

module Apiwork
  module API
    class InfoBuilder
      # @api public
      # Defines contact information for the API.
      #
      # Used within the `contact` block in {API::InfoBuilder}.
      class ContactBuilder
        attr_reader :data

        def initialize
          @data = {}
        end

        # @api public
        # Sets the contact name.
        #
        # @param text [String] the contact name
        # @return [void]
        #
        # @example
        #   contact do
        #     name 'API Support'
        #   end
        def name(text)
          @data[:name] = text
        end

        # @api public
        # Sets the contact email.
        #
        # @param text [String] the contact email
        # @return [void]
        #
        # @example
        #   contact do
        #     email 'support@example.com'
        #   end
        def email(text)
          @data[:email] = text
        end

        # @api public
        # Sets the contact URL.
        #
        # @param text [String] the contact URL
        # @return [void]
        #
        # @example
        #   contact do
        #     url 'https://example.com/support'
        #   end
        def url(text)
          @data[:url] = text
        end
      end
    end
  end
end
