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
      # @param value [String] the title
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
      # @param value [String] the version (e.g. '1.0.0')
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
      # The terms of service URL.
      #
      # @param url [String] the terms of service URL
      # @return [String, nil]
      #
      # @example
      #   terms_of_service 'https://example.com/terms'
      #   info.terms_of_service  # => "https://example.com/terms"
      def terms_of_service(url = nil)
        return @terms_of_service if url.nil?

        @terms_of_service = url
      end

      # @api public
      # Contact information.
      #
      # @yield block evaluated in {Contact} context
      # @return [Contact, nil]
      # @see API::Info::Contact
      #
      # @example
      #   contact do
      #     name 'Support'
      #   end
      #   info.contact.name  # => "Support"
      def contact(&block)
        return @contact unless block

        @contact = Contact.new
        @contact.instance_eval(&block)
      end

      # @api public
      # License information.
      #
      # @yield block evaluated in {License} context
      # @return [License, nil]
      # @see API::Info::License
      #
      # @example
      #   license do
      #     name 'MIT'
      #   end
      #   info.license.name  # => "MIT"
      def license(&block)
        return @license unless block

        @license = License.new
        @license.instance_eval(&block)
      end

      # @api public
      # Server definitions.
      #
      # Can be called multiple times to define multiple servers.
      #
      # @yield block evaluated in {Server} context
      # @return [Array<Server>]
      # @see API::Info::Server
      #
      # @example
      #   server do
      #     url 'https://api.example.com'
      #     description 'Production'
      #   end
      #   info.server  # => [#<Server ...>]
      def server(&block)
        return @servers unless block

        server = Server.new
        server.instance_eval(&block)
        @servers << server
      end

      # @api public
      # A short summary.
      #
      # @param value [String] the summary
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
      # A detailed description.
      #
      # @param value [String] the description (supports Markdown)
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
      # Tags for the API.
      #
      # @param values [Array<String>] the tags
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
      #
      # @example
      #   info.deprecated?  # => true
      def deprecated?
        @deprecated
      end
    end
  end
end
