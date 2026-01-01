# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
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

        # @return [String, nil] contact name
        def name
          @data[:name]
        end

        # @return [String, nil] contact email
        def email
          @data[:email]
        end

        # @return [String, nil] contact URL
        def url
          @data[:url]
        end
      end
    end
  end
end
