# frozen_string_literal: true

module Apiwork
  module API
    module Info
      # @api private
      class Builder
        # @api private
        attr_reader :info

        def initialize
          @info = {}
        end

        # Sets the API title.
        #
        # @param text [String] API title
        def title(text)
          @info[:title] = text
        end

        # Sets the API version.
        #
        # @param text [String] API version (e.g., '1.0.0')
        def version(text)
          @info[:version] = text
        end

        # Sets the terms of service URL.
        #
        # @param url [String] URL to terms of service
        def terms_of_service(url)
          @info[:terms_of_service] = url
        end

        # Defines contact information.
        #
        # @yield block with name, email, url methods
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

        # Defines license information.
        #
        # @yield block with name, url methods
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

        # Adds a server URL.
        #
        # Multiple servers can be added by calling this method multiple times.
        #
        # @param url [String] server URL
        # @param description [String] server description (optional)
        #
        # @example
        #   info do
        #     server url: 'https://api.example.com', description: 'Production'
        #     server url: 'https://staging.example.com', description: 'Staging'
        #   end
        def server(url:, description: nil)
          @info[:servers] ||= []
          @info[:servers] << { url: url, description: description }.compact
        end

        # Sets a short API summary.
        #
        # @param text [String] API summary
        def summary(text)
          @info[:summary] = text
        end

        # Sets a detailed API description.
        #
        # Supports Markdown formatting.
        #
        # @param text [String] API description
        def description(text)
          @info[:description] = text
        end

        # Sets default tags for the API.
        #
        # @param tags_list [Array<String,Symbol>] tag names
        def tags(*tags_list)
          @info[:tags] = tags_list.flatten
        end

        # Marks the entire API as deprecated.
        #
        # @param value [Boolean] deprecation status (default: true)
        def deprecated(value = true)
          @info[:deprecated] = value
        end
      end
    end
  end
end
