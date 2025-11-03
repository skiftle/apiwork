# frozen_string_literal: true

module Apiwork
  module API
    class DocBuilder
      attr_reader :documentation

      def initialize(level: :resource)
        @documentation = {}
        @level = level # :api or :resource
      end

      # === API-LEVEL FIELDS (only for level: :api) ===

      def title(text)
        @documentation[:title] = text if @level == :api
      end

      def version(text)
        @documentation[:version] = text if @level == :api
      end

      def terms_of_service(url)
        @documentation[:terms_of_service] = url if @level == :api
      end

      def contact(&block)
        return unless @level == :api

        builder = ContactBuilder.new
        builder.instance_eval(&block)
        @documentation[:contact] = builder.data
      end

      def license(&block)
        return unless @level == :api

        builder = LicenseBuilder.new
        builder.instance_eval(&block)
        @documentation[:license] = builder.data
      end

      def server(url:, description: nil)
        return unless @level == :api

        @documentation[:servers] ||= []
        @documentation[:servers] << { url: url, description: description }.compact
      end

      # === COMMON FIELDS (all levels) ===

      def summary(text)
        @documentation[:summary] = text
      end

      def description(text)
        @documentation[:description] = text
      end

      def tags(*tags_list)
        @documentation[:tags] = tags_list.flatten
      end

      def deprecated(value = true)
        @documentation[:deprecated] = value
      end

      def internal(value = true)
        @documentation[:internal] = value
      end

      # === NESTED BLOCKS (only for level: :resource) ===

      def actions(&block)
        return unless @level == :resource

        builder = ActionsBuilder.new
        builder.instance_eval(&block)
        @documentation[:actions] = builder.actions
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
          @actions[:index] = build_action_doc(&block)
        end

        def show(&block)
          @actions[:show] = build_action_doc(&block)
        end

        def create(&block)
          @actions[:create] = build_action_doc(&block)
        end

        def update(&block)
          @actions[:update] = build_action_doc(&block)
        end

        def destroy(&block)
          @actions[:destroy] = build_action_doc(&block)
        end

        # Handle custom actions (member and collection actions)
        def method_missing(name, &block)
          @actions[name] = build_action_doc(&block)
        end

        def respond_to_missing?(*, **)
          true
        end

        private

        def build_action_doc(&block)
          builder = ActionDocBuilder.new
          builder.instance_eval(&block) if block
          builder.documentation
        end
      end

      class ActionDocBuilder
        attr_reader :documentation

        def initialize
          @documentation = {}
        end

        def summary(text)
          @documentation[:summary] = text
        end

        def description(text)
          @documentation[:description] = text
        end

        def tags(*tags_list)
          @documentation[:tags] = tags_list.flatten
        end

        def deprecated(value = true)
          @documentation[:deprecated] = value
        end

        def internal(value = true)
          @documentation[:internal] = value
        end
      end
    end
  end
end
