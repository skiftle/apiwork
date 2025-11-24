# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class RecordResponse
        def self.render(load_result, user_meta, query, schema_class, context)
          new(load_result, user_meta, query, schema_class, context).render
        end

        def initialize(load_result, user_meta, query, schema_class, context)
          @load_result = load_result
          @user_meta = user_meta
          @query = query
          @schema_class = schema_class
          @context = context
        end

        def render
          return { meta: @user_meta.presence || {} } if @context.delete?

          root_key = @schema_class.root_key.singular
          record = @load_result.data

          response = { root_key => record }
          response[:meta] = @user_meta if @user_meta.present?
          response
        end
      end
    end
  end
end
