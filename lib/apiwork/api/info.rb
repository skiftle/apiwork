# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # API info block.
    #
    # Used within the `info` block in {API::Base}.
    class Info
      def initialize
        @contact = nil
        @deprecated = false
        @description = nil
        @license = nil
        @servers = []
        @summary = nil
        @tags = []
        @terms_of_service = nil
        @title = nil
        @version = nil
      end

      # @api public
      # The API title.
      #
      # @param value [String, nil] (nil)
      # @return [String, nil]
      #
      # @example
      #   title 'Invoice API'
      #   info.title  # => "Invoice API"
      def title(value = nil)
        return @title if value.nil?

        @title = value
      end

      # @api public
      # The API version.
      #
      # @param value [String, nil] (nil)
      # @return [String, nil]
      #
      # @example
      #   version '1.0.0'
      #   info.version  # => "1.0.0"
      def version(value = nil)
        return @version if value.nil?

        @version = value
      end

      # @api public
      # The API terms of service.
      #
      # @param value [String, nil] (nil)
      # @return [String, nil]
      #
      # @example
      #   terms_of_service 'https://example.com/terms'
      #   info.terms_of_service  # => "https://example.com/terms"
      def terms_of_service(value = nil)
        return @terms_of_service if value.nil?

        @terms_of_service = value
      end

      # @api public
      # The API contact.
      #
      # @yield block for defining contact info
      # @yieldparam contact [Contact]
      # @return [Contact, nil]
      #
      # @example instance_eval style
      #   contact do
      #     name 'Support'
      #     email 'support@example.com'
      #   end
      #
      # @example yield style
      #   contact do |contact|
      #     contact.name 'Support'
      #     contact.email 'support@example.com'
      #   end
      def contact(&block)
        return @contact unless block

        @contact = Contact.new
        block.arity.positive? ? yield(@contact) : @contact.instance_eval(&block)
        @contact
      end

      # @api public
      # The API license.
      #
      # @yield block for defining license info
      # @yieldparam license [License]
      # @return [License, nil]
      #
      # @example instance_eval style
      #   license do
      #     name 'MIT'
      #     url 'https://opensource.org/licenses/MIT'
      #   end
      #
      # @example yield style
      #   license do |license|
      #     license.name 'MIT'
      #     license.url 'https://opensource.org/licenses/MIT'
      #   end
      def license(&block)
        return @license unless block

        @license = License.new
        block.arity.positive? ? yield(@license) : @license.instance_eval(&block)
        @license
      end

      # @api public
      # Defines a server for the API.
      #
      # Can be called multiple times.
      #
      # @yield block for defining server info
      # @yieldparam server [Server]
      # @return [Array<Server>]
      #
      # @example instance_eval style
      #   server do
      #     url 'https://api.example.com'
      #     description 'Production'
      #   end
      #
      # @example yield style
      #   server do |server|
      #     server.url 'https://api.example.com'
      #     server.description 'Production'
      #   end
      def server(&block)
        return @servers unless block

        server = Server.new
        block.arity.positive? ? yield(server) : server.instance_eval(&block)
        @servers << server
      end

      # @api public
      # The API summary.
      #
      # @param value [String, nil] (nil)
      # @return [String, nil]
      #
      # @example
      #   summary 'Invoice management API'
      #   info.summary  # => "Invoice management API"
      def summary(value = nil)
        return @summary if value.nil?

        @summary = value
      end

      # @api public
      # The API description.
      #
      # @param value [String, nil] (nil)
      # @return [String, nil]
      #
      # @example
      #   description 'Full-featured API for managing invoices and payments.'
      #   info.description  # => "Full-featured..."
      def description(value = nil)
        return @description if value.nil?

        @description = value
      end

      # @api public
      # The API tags.
      #
      # @param values [Array<String>]
      # @return [Array<String>]
      #
      # @example
      #   tags 'invoices', 'payments'
      #   info.tags  # => ["invoices", "payments"]
      def tags(*values)
        return @tags if values.empty?

        @tags = values.flatten
      end

      # @api public
      # Marks the API as deprecated.
      #
      # @return [void]
      #
      # @example
      #   info do
      #     deprecated!
      #   end
      def deprecated!
        @deprecated = true
      end

      # @api public
      # Whether the API is deprecated.
      #
      # @return [Boolean]
      def deprecated?
        @deprecated
      end
    end
  end
end
