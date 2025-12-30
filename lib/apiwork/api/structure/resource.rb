# frozen_string_literal: true

module Apiwork
  module API
    class Structure
      class Resource
        attr_reader :contract_class_name,
                    :controller,
                    :except,
                    :name,
                    :only,
                    :parent,
                    :path,
                    :resources,
                    :singular

        attr_accessor :contract_class

        def initialize(
          name:,
          singular:,
          contract_class_name:,
          controller: nil,
          parent: nil,
          path: nil,
          only: nil,
          except: nil
        )
          @name = name
          @singular = singular
          @contract_class_name = contract_class_name
          @controller = controller
          @parent = parent
          @path = path
          @only = only
          @except = except
          @crud_actions = determine_crud_actions(singular, except:, only:)
          @custom_actions = []
          @resources = {}
        end

        def actions
          @actions ||= build_actions
        end

        def has_index?
          @crud_actions.include?(:index) || @resources.values.any?(&:has_index?)
        end

        def schema_class
          contract_class&.schema_class
        end

        def add_action(name, method:, type:)
          @custom_actions << Action.new(name, method:, type:)
        end

        def member_actions
          @custom_actions.select(&:member?).index_by(&:name)
        end

        def collection_actions
          @custom_actions.select(&:collection?).index_by(&:name)
        end

        def add_resource(resource)
          @resources[resource.name] = resource
        end

        def find_resource(name = nil, &block)
          return find_resource_by_block(&block) if block
          return @resources[name] if @resources[name]

          @resources.each_value do |resource|
            found = resource.find_resource(name)
            return found if found
          end

          nil
        end

        def each_resource(&block)
          @resources.each_value do |resource|
            yield resource
            resource.each_resource(&block)
          end
        end

        def resolve_contract_class
          return @contract_class if @contract_class
          return nil unless @contract_class_name

          @contract_class = @contract_class_name.constantize
        rescue NameError
          nil
        end

        private

        def find_resource_by_block(&block)
          @resources.each_value do |resource|
            return resource if yield(resource)

            found = resource.find_resource(&block)
            return found if found
          end

          nil
        end

        def build_actions
          actions = @crud_actions.map { |name| Action.new(name) }
          actions.concat(@custom_actions)
          actions.index_by(&:name)
        end

        def determine_crud_actions(singular, except:, only:)
          if only
            Array(only).map(&:to_sym)
          else
            default_actions = if singular
                                [:show, :create, :update, :destroy]
                              else
                                [:index, :show, :create, :update, :destroy]
                              end

            if except
              default_actions - Array(except).map(&:to_sym)
            else
              default_actions
            end
          end
        end
      end
    end
  end
end
