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
        @deprecated = nil
        @description = nil
        @license = nil
        @servers = nil
        @summary = nil
        @tags = nil
        @terms_of_service = nil
        @title = nil
        @version = nil
      end

      def to_h
        {
          contact: @contact&.to_h,
          deprecated: @deprecated,
          description: @description,
          license: @license&.to_h,
          servers: @servers&.map(&:to_h),
          summary: @summary,
          tags: @tags,
          terms_of_service: @terms_of_service,
          title: @title,
          version: @version,
        }
      end

      # @api public
      # Sets the API title.
      #
      # @param title [String] the title
      # @return [void]
      #
      # @example
      #   info do
      #     title 'Invoice API'
      #   end
      def title(title)
        @title = title
      end

      # @api public
      # Sets the API version.
      #
      # @param version [String] the version (e.g. '1.0.0')
      # @return [void]
      #
      # @example
      #   info do
      #     version '1.0.0'
      #   end
      def version(version)
        @version = version
      end

      # @api public
      # Sets the terms of service URL.
      #
      # @param url [String] the terms of service URL
      # @return [void]
      #
      # @example
      #   info do
      #     terms_of_service 'https://example.com/terms'
      #   end
      def terms_of_service(url)
        @terms_of_service = url
      end

      # @api public
      # Defines contact information.
      #
      # @yield block evaluated in {Contact} context
      # @return [void]
      # @see API::Info::Contact
      #
      # @example
      #   contact do
      #     name 'Support'
      #   end
      def contact(&block)
        @contact = Contact.new
        @contact.instance_eval(&block)
      end

      # @api public
      # Defines license information.
      #
      # @yield block evaluated in {License} context
      # @return [void]
      # @see API::Info::License
      #
      # @example
      #   license do
      #     name 'MIT'
      #   end
      def license(&block)
        @license = License.new
        @license.instance_eval(&block)
      end

      # @api public
      # Adds a server to the API specification.
      #
      # Can be called multiple times to define multiple servers.
      #
      # @yield block evaluated in {Server} context
      # @return [void]
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
        server = Server.new
        server.instance_eval(&block)
        @servers ||= []
        @servers << server
      end

      # @api public
      # Sets a short summary for the API.
      #
      # @param summary [String] the summary
      # @return [void]
      #
      # @example
      #   info do
      #     summary 'Invoice management API'
      #   end
      def summary(summary)
        @summary = summary
      end

      # @api public
      # Sets a detailed description for the API.
      #
      # @param description [String] the description (supports Markdown)
      # @return [void]
      #
      # @example
      #   info do
      #     description 'Full-featured API for managing invoices and payments.'
      #   end
      def description(description)
        @description = description
      end

      # @api public
      # Sets tags for the API.
      #
      # @param tags [Array<String>] list of tags
      # @return [void]
      #
      # @example
      #   info do
      #     tags 'invoices', 'payments'
      #   end
      def tags(*tags)
        @tags = tags.flatten
      end

      # @api public
      # Marks the API as deprecated.
      #
      # @return [void]
      #
      # @example
      #   info do
      #     deprecated
      #   end
      def deprecated
        @deprecated = true
      end
    end
  end
end
