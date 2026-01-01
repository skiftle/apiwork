# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Defines API metadata.
    #
    # Sets title, version, contact, license, and servers.
    # Used by spec generators via {Spec.generate}.
    class InfoBuilder
      attr_reader :info

      def initialize
        @info = {}
      end

      # @api public
      # Sets the API title.
      #
      # @param text [String] the title
      # @return [void]
      #
      # @example
      #   info do
      #     title 'Invoice API'
      #   end
      def title(text)
        @info[:title] = text
      end

      # @api public
      # Sets the API version.
      #
      # @param text [String] the version (e.g. '1.0.0')
      # @return [void]
      #
      # @example
      #   info do
      #     version '1.0.0'
      #   end
      def version(text)
        @info[:version] = text
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
        @info[:terms_of_service] = url
      end

      # @api public
      # Defines contact information for the API.
      #
      # @yield block to configure contact details
      # @return [void]
      #
      # @example
      #   info do
      #     contact do
      #       name 'API Support'
      #       email 'support@example.com'
      #       url 'https://example.com/support'
      #     end
      #   end
      def contact(&block)
        builder = ContactBuilder.new
        builder.instance_eval(&block)
        @info[:contact] = builder.data
      end

      # @api public
      # Defines license information for the API.
      #
      # @yield block to configure license details
      # @return [void]
      #
      # @example
      #   info do
      #     license do
      #       name 'MIT'
      #       url 'https://opensource.org/licenses/MIT'
      #     end
      #   end
      def license(&block)
        builder = LicenseBuilder.new
        builder.instance_eval(&block)
        @info[:license] = builder.data
      end

      # @api public
      # Adds a server to the API specification.
      #
      # @param url [String] the server URL
      # @param description [String, nil] optional server description
      # @return [void]
      #
      # @example
      #   info do
      #     server url: 'https://api.example.com', description: 'Production'
      #     server url: 'https://staging-api.example.com', description: 'Staging'
      #   end
      def server(url:, description: nil)
        @info[:servers] ||= []
        @info[:servers] << { description:, url: }.compact
      end

      # @api public
      # Sets a short summary for the API.
      #
      # @param text [String] the summary
      # @return [void]
      #
      # @example
      #   info do
      #     summary 'Invoice management API'
      #   end
      def summary(text)
        @info[:summary] = text
      end

      # @api public
      # Sets a detailed description for the API.
      #
      # @param text [String] the description (supports Markdown)
      # @return [void]
      #
      # @example
      #   info do
      #     description 'Full-featured API for managing invoices and payments.'
      #   end
      def description(text)
        @info[:description] = text
      end

      # @api public
      # Sets tags for the API.
      #
      # @param tags_list [Array<String>] list of tags
      # @return [void]
      #
      # @example
      #   info do
      #     tags 'invoices', 'payments'
      #   end
      def tags(*tags_list)
        @info[:tags] = tags_list.flatten
      end

      # @api public
      # Marks the API as deprecated.
      #
      # @param value [Boolean] whether the API is deprecated
      # @return [void]
      #
      # @example
      #   info do
      #     deprecated true
      #   end
      def deprecated(value = true)
        @info[:deprecated] = value
      end
    end
  end
end
