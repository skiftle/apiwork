# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps API metadata/info.
      #
      # @example
      #   info = api.info
      #   info.title            # => "My API"
      #   info.version          # => "1.0.0"
      #   info.description      # => "API for managing resources"
      #   info.contact&.email   # => "support@example.com"
      #   info.license&.name    # => "MIT"
      class Info
        def initialize(data)
          @data = data || {}
        end

        # @return [String, nil] API title
        def title
          @data[:title]
        end

        # @return [String, nil] API version
        def version
          @data[:version]
        end

        # @return [String, nil] API description
        def description
          @data[:description]
        end

        # @return [String, nil] short summary
        def summary
          @data[:summary]
        end

        # @return [String, nil] terms of service URL
        def terms_of_service
          @data[:terms_of_service]
        end

        # @return [Contact, nil] contact information
        # @see Contact
        def contact
          @contact ||= @data[:contact] ? Contact.new(@data[:contact]) : nil
        end

        # @return [License, nil] license information
        # @see License
        def license
          @license ||= @data[:license] ? License.new(@data[:license]) : nil
        end

        # @return [Array<Server>] server definitions
        # @see Server
        def servers
          @servers ||= (@data[:servers] || []).map { |s| Server.new(s) }
        end
      end
    end
  end
end
