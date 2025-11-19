# frozen_string_literal: true

module Apiwork
  module API
    module Info
      class Builder
        attr_reader :info

        def initialize
          @info = {}
        end

        # === API-LEVEL FIELDS ===

        def title(text)
          @info[:title] = text
        end

        def version(text)
          @info[:version] = text
        end

        def terms_of_service(url)
          @info[:terms_of_service] = url
        end

        def contact(&block)
          builder = ContactBuilder.new
          builder.instance_eval(&block)
          @info[:contact] = builder.data
        end

        def license(&block)
          builder = LicenseBuilder.new
          builder.instance_eval(&block)
          @info[:license] = builder.data
        end

        def server(url:, description: nil)
          @info[:servers] ||= []
          @info[:servers] << { url: url, description: description }.compact
        end

        # === COMMON FIELDS ===

        def summary(text)
          @info[:summary] = text
        end

        def description(text)
          @info[:description] = text
        end

        def tags(*tags_list)
          @info[:tags] = tags_list.flatten
        end

        def deprecated(value = true)
          @info[:deprecated] = value
        end

        def internal(value = true)
          @info[:internal] = value
        end

        # === NESTED BUILDER CLASSES ===

        class ContactBuilder
          attr_reader :data

          def initialize
            @data = {}
          end

          def name(text)
            @data[:name] = text
          end

          def email(text)
            @data[:email] = text
          end

          def url(text)
            @data[:url] = text
          end
        end

        class LicenseBuilder
          attr_reader :data

          def initialize
            @data = {}
          end

          def name(text)
            @data[:name] = text
          end

          def url(text)
            @data[:url] = text
          end
        end
      end
    end
  end
end
