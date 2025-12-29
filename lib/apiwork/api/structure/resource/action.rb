# frozen_string_literal: true

module Apiwork
  module API
    class Structure
      class Resource
        class Action
          CRUD = %i[index show create update destroy].freeze
          METHODS = {
            create: :post,
            destroy: :delete,
            index: :get,
            show: :get,
            update: :patch,
          }.freeze

          attr_reader :method,
                      :name,
                      :type

          def initialize(name, method: nil, type: nil)
            @name = name.to_sym
            @type = type || default_type
            @method = method || default_method
          end

          def member?
            type == :member
          end

          def collection?
            type == :collection
          end

          def crud?
            CRUD.include?(name)
          end

          private

          def default_type
            name == :index ? :collection : :member
          end

          def default_method
            METHODS[name] || :get
          end
        end
      end
    end
  end
end
