# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Description
        def summary(text)
          @pending_metadata[:summary] = text
        end

        def description(text)
          @pending_metadata[:description] = text
        end

        def tags(*tags_list)
          @pending_metadata[:tags] = tags_list.flatten
        end

        def describe(action, summary: nil, description: nil, tags: nil, deprecated: false, operation_id: nil)
          @pending_metadata[:actions] ||= {}
          @pending_metadata[:actions][action] = {
            summary: summary,
            description: description,
            tags: tags,
            deprecated: deprecated,
            operation_id: operation_id
          }.compact
        end
      end
    end
  end
end
