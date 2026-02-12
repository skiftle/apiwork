# frozen_string_literal: true

module Apiwork
  module API
    class Registry < Apiwork::Registry
      class << self
        def register(api_class)
          return unless api_class.base_path

          store[normalize_key(api_class.base_path)] = api_class
        end

        def find(base_path)
          return nil unless base_path

          super
        end

        def unregister(base_path)
          delete(base_path) if base_path
        end

        private

        def normalize_key(base_path)
          return :root if base_path == '/'

          base_path.delete_prefix('/').underscore.to_sym
        end
      end
    end
  end
end
