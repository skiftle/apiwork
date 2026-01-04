# frozen_string_literal: true

module Apiwork
  module Introspection
    class API
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
          @data = data
        end

        # @api public
        # @return [String, nil] API title
        def title
          @data[:title]
        end

        # @api public
        # @return [String, nil] API version
        def version
          @data[:version]
        end

        # @api public
        # @return [String, nil] API description
        def description
          @data[:description]
        end

        # @api public
        # @return [String, nil] short summary
        def summary
          @data[:summary]
        end

        # @api public
        # @return [String, nil] terms of service URL
        def terms_of_service
          @data[:terms_of_service]
        end

        # @api public
        # @return [Info::Contact, nil] contact information
        # @see Info::Contact
        def contact
          @contact ||= @data[:contact] ? Contact.new(@data[:contact]) : nil
        end

        # @api public
        # @return [Info::License, nil] license information
        # @see Info::License
        def license
          @license ||= @data[:license] ? License.new(@data[:license]) : nil
        end

        # @api public
        # @return [Array<Info::Server>] server definitions
        # @see Info::Server
        def servers
          @servers ||= @data[:servers].map { |server| Server.new(server) }
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          {
            contact: contact&.to_h,
            description: description,
            license: license&.to_h,
            servers: servers.map(&:to_h),
            summary: summary,
            terms_of_service: terms_of_service,
            title: title,
            version: version,
          }
        end
      end
    end
  end
end
