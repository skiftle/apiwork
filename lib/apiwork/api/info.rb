# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Defines API metadata.
    #
    # Sets title, version, contact, license, and servers.
    # Used by export generators via {Export.generate}.
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
      # Sets or gets the API title.
      #
      # @param title [String] the title
      # @return [String, void]
      #
      # @example
      #   info do
      #     title 'Invoice API'
      #   end
      def title(title = nil)
        return @title if title.nil?

        @title = title
      end

      # @api public
      # Sets or gets the API version.
      #
      # @param version [String] the version (e.g. '1.0.0')
      # @return [String, void]
      #
      # @example
      #   info do
      #     version '1.0.0'
      #   end
      def version(version = nil)
        return @version if version.nil?

        @version = version
      end

      # @api public
      # Sets or gets the terms of service URL.
      #
      # @param url [String] the terms of service URL
      # @return [String, void]
      #
      # @example
      #   info do
      #     terms_of_service 'https://example.com/terms'
      #   end
      def terms_of_service(url = nil)
        return @terms_of_service if url.nil?

        @terms_of_service = url
      end

      # @api public
      # Sets or gets contact information.
      #
      # @yield block evaluated in {Contact} context
      # @return [Contact, void]
      # @see API::Info::Contact
      #
      # @example
      #   contact do
      #     name 'Support'
      #   end
      def contact(&block)
        return @contact unless block

        @contact = Contact.new
        @contact.instance_eval(&block)
      end

      # @api public
      # Sets or gets license information.
      #
      # @yield block evaluated in {License} context
      # @return [License, void]
      # @see API::Info::License
      #
      # @example
      #   license do
      #     name 'MIT'
      #   end
      def license(&block)
        return @license unless block

        @license = License.new
        @license.instance_eval(&block)
      end

      # @api public
      # Adds a server or gets all servers.
      #
      # Can be called multiple times to define multiple servers.
      #
      # @yield block evaluated in {Server} context
      # @return [Array<Server>, void]
      # @see API::Info::Server
      #
      # @example
      #   info do
      #     server do
      #       url 'https://api.example.com'
      #       description 'Production'
      #     end
      #     server do
      #       url 'https://staging-api.example.com'
      #       description 'Staging'
      #     end
      #   end
      def server(&block)
        return @servers unless block

        server = Server.new
        server.instance_eval(&block)
        @servers << server
      end

      # @api public
      # Sets or gets a short summary for the API.
      #
      # @param summary [String] the summary
      # @return [String, void]
      #
      # @example
      #   info do
      #     summary 'Invoice management API'
      #   end
      def summary(summary = nil)
        return @summary if summary.nil?

        @summary = summary
      end

      # @api public
      # Sets or gets a detailed description for the API.
      #
      # @param description [String] the description (supports Markdown)
      # @return [String, void]
      #
      # @example
      #   info do
      #     description 'Full-featured API for managing invoices and payments.'
      #   end
      def description(description = nil)
        return @description if description.nil?

        @description = description
      end

      # @api public
      # Sets or gets tags for the API.
      #
      # @param values [Array<String>] list of tags
      # @return [Array<String>, void]
      #
      # @example
      #   info do
      #     tags 'invoices', 'payments'
      #   end
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

      def deprecated?
        @deprecated
      end
    end
  end
end
