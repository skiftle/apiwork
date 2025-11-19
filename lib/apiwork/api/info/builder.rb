# frozen_string_literal: true

module Apiwork
  module API
    module Info
      class Builder
        attr_reader :info

        def initialize(level: :resource)
          @info = {}
          @level = level # :api or :resource
        end

        # === API-LEVEL FIELDS (only for level: :api) ===

        def title(text)
          @info[:title] = text if @level == :api
        end

        def version(text)
          @info[:version] = text if @level == :api
        end

        def terms_of_service(url)
          @info[:terms_of_service] = url if @level == :api
        end

        def contact(&block)
          return unless @level == :api

          builder = ContactBuilder.new
          builder.instance_eval(&block)
          @info[:contact] = builder.data
        end

        def license(&block)
          return unless @level == :api

          builder = LicenseBuilder.new
          builder.instance_eval(&block)
          @info[:license] = builder.data
        end

        def server(url:, description: nil)
          return unless @level == :api

          @info[:servers] ||= []
          @info[:servers] << { url: url, description: description }.compact
        end

        # === COMMON FIELDS (all levels) ===

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

        # === NESTED BLOCKS (only for level: :resource) ===

        def actions(&block)
          return unless @level == :resource

          builder = ActionsBuilder.new
          builder.instance_eval(&block)
          @info[:actions] = builder.actions
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

        class ActionsBuilder
          attr_reader :actions

          def initialize
            @actions = {}
          end

          def index(&block)
            @actions[:index] = build_action_info(&block)
          end

          def show(&block)
            @actions[:show] = build_action_info(&block)
          end

          def create(&block)
            @actions[:create] = build_action_info(&block)
          end

          def update(&block)
            @actions[:update] = build_action_info(&block)
          end

          def destroy(&block)
            @actions[:destroy] = build_action_info(&block)
          end

          # Handle custom actions (member and collection actions)
          def method_missing(name, &block)
            @actions[name] = build_action_info(&block)
          end

          def respond_to_missing?(*, **)
            true
          end

          private

          def build_action_info(&block)
            builder = ActionInfoBuilder.new
            builder.instance_eval(&block) if block
            builder.info
          end
        end

        class ActionInfoBuilder
          attr_reader :info

          def initialize
            @info = {}
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

          def internal(value = true)
            @info[:internal] = value
          end
        end
      end
    end
  end
end
