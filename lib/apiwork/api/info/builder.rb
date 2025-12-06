# frozen_string_literal: true

module Apiwork
  module API
    module Info
      class Builder
        attr_reader :info

        def initialize
          @info = {}
        end

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

      end
    end
  end
end
