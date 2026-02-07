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
        def initialize(dump)
          @dump = dump
        end

        # @api public
        # The API title.
        #
        # @return [String, nil]
        def title
          @dump[:title]
        end

        # @api public
        # The API version.
        #
        # @return [String, nil]
        def version
          @dump[:version]
        end

        # @api public
        # The API description.
        #
        # @return [String, nil]
        def description
          @dump[:description]
        end

        # @api public
        # The API summary.
        #
        # @return [String, nil]
        def summary
          @dump[:summary]
        end

        # @api public
        # The API terms of service.
        #
        # @return [String, nil]
        def terms_of_service
          @dump[:terms_of_service]
        end

        # @api public
        # The API contact.
        #
        # @return [Info::Contact, nil]
        # @see Info::Contact
        def contact
          @contact ||= @dump[:contact] ? Contact.new(@dump[:contact]) : nil
        end

        # @api public
        # The API license.
        #
        # @return [Info::License, nil]
        # @see Info::License
        def license
          @license ||= @dump[:license] ? License.new(@dump[:license]) : nil
        end

        # @api public
        # The API servers.
        #
        # @return [Array<Info::Server>]
        # @see Info::Server
        def servers
          @servers ||= @dump[:servers].map { |server| Server.new(server) }
        end

        # @api public
        # Converts this info to a hash.
        #
        # @return [Hash]
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
