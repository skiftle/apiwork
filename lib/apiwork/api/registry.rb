# frozen_string_literal: true

module Apiwork
  module API
    class Registry < Apiwork::Registry
      class << self
        def register(api_class)
          return unless api_class.structure&.path

          store[normalize_key(api_class.structure.path)] = api_class
        end

        def find(path)
          return nil unless path

          super
        end

        def all
          values.uniq
        end

        def unregister(path)
          delete(path) if path
        end

        private

        def normalize_key(path)
          return :root if path == '/'

          path.delete_prefix('/').underscore.to_sym
        end
      end
    end
  end
end
