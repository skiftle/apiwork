# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Defines API metadata.
    #
    # Sets title, version, contact, license, and servers.
    # Used by spec generators via {Spec.generate}.
    class Info
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
        builder = Contact.new
        builder.instance_eval(&block)
        @info[:contact] = builder.data
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
        builder = License.new
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
      def server(description: nil, url:)
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
