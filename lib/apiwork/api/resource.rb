# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # DSL context for defining API resources and routes.
    #
    # Resource provides the DSL available inside `resources` and `resource`
    # blocks. Methods include nested resources, custom actions, and concerns.
    #
    # @example Defining resources with actions
    #   Apiwork::API.define '/api/v1' do
    #     resources :invoices do
    #       member do
    #         post :send
    #         get :preview
    #       end
    #
    #       collection do
    #         get :search
    #       end
    #
    #       resources :items
    #     end
    #   end
    class Resource
      attr_reader :api_class,
                  :constraints,
                  :contract_class_name,
                  :controller,
                  :defaults,
                  :except,
                  :name,
                  :only,
                  :param,
                  :path,
                  :singular

      attr_accessor :contract_class

      def initialize(
        api_class,
        constraints: nil,
        contract_class_name: nil,
        controller: nil,
        defaults: nil,
        except: nil,
        name: nil,
        only: nil,
        param: nil,
        path: nil,
        singular: false
      )
        @api_class = api_class
        @constraints = constraints
        @contract_class_name = contract_class_name
        @controller = controller
        @defaults = defaults
        @except = except
        @name = name
        @only = only
        @param = param
        @path = path
        @singular = singular

        @crud_actions = name ? determine_crud_actions(singular, except:, only:) : []
        @custom_actions = []
        @resources = {}
        @concerns = {}
        @resource_stack = []
        @current_options = nil
        @in_member_block = false
        @in_collection_block = false
      end

      def has_index_actions?
        @resources.values.any? { |resource| resource.actions.key?(:index) || resource.has_index_actions? }
      end

      def representation_classes
        @representation_classes ||= collect_all_representation_classes
      end

      def representation_class
        contract_class&.representation_class
      end

      def actions
        @actions ||= build_actions
      end

      def member_actions
        @custom_actions.select(&:member?).index_by(&:name)
      end

      def collection_actions
        @custom_actions.select(&:collection?).index_by(&:name)
      end

      def add_action(action_name, method:, type:)
        @custom_actions << Action.new(action_name, method:, type:)
      end

      def add_resource(resource)
        @resources[resource.name] = resource
      end

      def find_resource(resource_name = nil, &block)
        return find_resource_by_block(&block) if block
        return @resources[resource_name] if @resources[resource_name]

        @resources.each_value do |resource|
          found = resource.find_resource(resource_name)
          return found if found
        end

        nil
      end

      def find_resource_for_path(resource_path)
        current = nil
        resource_path.split('/').each do |part|
          next if part.empty?

          resource_name = part.tr('-', '_').to_sym
          target = current ? current.resources : @resources
          found = target[resource_name] || target[resource_name.to_s.singularize.to_sym]
          next unless found

          current = found
        end
        current
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

      # @api public
      # Defines a plural resource with standard CRUD actions.
      #
      # Default actions: :index, :show, :create, :update, :destroy.
      #
      # @param resource_name [Symbol] resource name (plural)
      # @param concerns [Array<Symbol>, nil] (nil) concerns to include
      # @param constraints [Hash, Proc, nil] (nil) route constraints
      # @param contract [String, nil] (nil) custom contract path
      # @param controller [String, nil] (nil) custom controller path
      # @param defaults [Hash, nil] (nil) default route parameters
      # @param except [Array<Symbol>, nil] (nil) actions to exclude
      # @param only [Array<Symbol>, nil] (nil) only these CRUD actions
      # @param param [Symbol, nil] (nil) custom ID parameter
      # @param path [String, nil] (nil) custom URL segment
      # @yield block for nested resources and custom actions
      # @yieldparam resource [Resource]
      # @return [Hash{Symbol => Resource}]
      #
      # @example instance_eval style
      #   resources :invoices do
      #     member { get :preview }
      #     resources :items
      #   end
      #
      # @example yield style
      #   resources :invoices do |resource|
      #     resource.member { |member| member.get :preview }
      #     resource.resources :items
      #   end
      def resources(
        resource_name = nil,
        concerns: nil,
        constraints: nil,
        contract: nil,
        controller: nil,
        defaults: nil,
        except: nil,
        only: nil,
        param: nil,
        path: nil,
        &block
      )
        return @resources if resource_name.nil?

        options = {
          constraints:,
          contract:,
          controller:,
          defaults:,
          except:,
          only:,
          param:,
          path:,
        }.compact
        build_resource(resource_name, options:, singular: false)

        @resource_stack.push(resource_name)

        self.concerns(*concerns) if concerns
        if block
          block.arity.positive? ? yield(self) : instance_eval(&block)
        end

        @resource_stack.pop
      end

      # @api public
      # Defines a singular resource (no index, no :id in URL).
      #
      # Default actions: :show, :create, :update, :destroy.
      #
      # @param resource_name [Symbol] resource name (singular)
      # @param concerns [Array<Symbol>, nil] (nil) concerns to include
      # @param constraints [Hash, Proc, nil] (nil) route constraints
      # @param contract [String, nil] (nil) custom contract path
      # @param controller [String, nil] (nil) custom controller path
      # @param defaults [Hash, nil] (nil) default route parameters
      # @param except [Array<Symbol>, nil] (nil) actions to exclude
      # @param only [Array<Symbol>, nil] (nil) only these CRUD actions
      # @param param [Symbol, nil] (nil) custom ID parameter
      # @param path [String, nil] (nil) custom URL segment
      # @yield block for nested resources and custom actions
      # @yieldparam resource [Resource]
      # @return [void]
      #
      # @example instance_eval style
      #   resource :profile do
      #     resources :settings
      #   end
      #
      # @example yield style
      #   resource :profile do |resource|
      #     resource.resources :settings
      #   end
      def resource(
        resource_name,
        concerns: nil,
        constraints: nil,
        contract: nil,
        controller: nil,
        defaults: nil,
        except: nil,
        only: nil,
        param: nil,
        path: nil,
        &block
      )
        options = {
          constraints:,
          contract:,
          controller:,
          defaults:,
          except:,
          only:,
          param:,
          path:,
        }.compact
        build_resource(resource_name, options:, singular: true)

        @resource_stack.push(resource_name)

        self.concerns(*concerns) if concerns
        if block
          block.arity.positive? ? yield(self) : instance_eval(&block)
        end

        @resource_stack.pop
      end

      # @api public
      # Applies options to all resources defined in the block.
      #
      # @param options [Hash] ({}) options to merge into nested resources
      # @yield block with resource definitions
      # @yieldparam resource [Resource]
      # @return [void]
      #
      # @example instance_eval style
      #   with_options only: [:index, :show] do
      #     resources :reports
      #     resources :analytics
      #   end
      #
      # @example yield style
      #   with_options only: [:index, :show] do |resource|
      #     resource.resources :reports
      #     resource.resources :analytics
      #   end
      def with_options(options = {}, &block)
        old_options = @current_options
        @current_options = merged_options(options)

        block.arity.positive? ? yield(self) : instance_eval(&block)

        @current_options = old_options
      end

      # @api public
      # Block for defining member actions (operate on :id).
      #
      # Member routes include :id in the path: `/invoices/:id/action`
      #
      # @yield block with HTTP verb methods
      # @yieldparam resource [Resource]
      # @return [void]
      #
      # @example instance_eval style
      #   member do
      #     post :send
      #     get :preview
      #   end
      #
      # @example yield style
      #   member do |member|
      #     member.post :send
      #     member.get :preview
      #   end
      def member(&block)
        @in_member_block = true
        block.arity.positive? ? yield(self) : instance_eval(&block)
        @in_member_block = false
      end

      # @api public
      # Block for defining collection actions.
      #
      # Collection routes don't include :id: `/invoices/action`
      #
      # @yield block with HTTP verb methods
      # @yieldparam resource [Resource]
      # @return [void]
      #
      # @example instance_eval style
      #   collection do
      #     get :search
      #     post :bulk_create
      #   end
      #
      # @example yield style
      #   collection do |collection|
      #     collection.get :search
      #     collection.post :bulk_create
      #   end
      def collection(&block)
        @in_collection_block = true
        block.arity.positive? ? yield(self) : instance_eval(&block)
        @in_collection_block = false
      end

      # @api public
      # Defines a GET action.
      #
      # @param action_names [Symbol, Array<Symbol>] action name(s)
      # @param on [Symbol] :member or :collection
      # @return [void]
      #
      # @example Inside member block
      #   member { get :preview }
      #
      # @example With on parameter
      #   get :search, on: :collection
      def get(action_names, on: nil)
        capture_actions(action_names, on:, method: :get)
      end

      # @api public
      # Defines a POST action.
      #
      # @param action_names [Symbol, Array<Symbol>] action name(s)
      # @param on [Symbol] :member or :collection
      # @return [void]
      #
      # @example
      #   member { post :send }
      def post(action_names, on: nil)
        capture_actions(action_names, on:, method: :post)
      end

      # @api public
      # Defines a PATCH action.
      #
      # @param action_names [Symbol, Array<Symbol>] action name(s)
      # @param on [Symbol] :member or :collection
      # @return [void]
      #
      # @example
      #   member { patch :mark_paid }
      def patch(action_names, on: nil)
        capture_actions(action_names, on:, method: :patch)
      end

      # @api public
      # Defines a PUT action.
      #
      # @param action_names [Symbol, Array<Symbol>] action name(s)
      # @param on [Symbol] :member or :collection
      # @return [void]
      #
      # @example
      #   member { put :replace }
      def put(action_names, on: nil)
        capture_actions(action_names, on:, method: :put)
      end

      # @api public
      # Defines a DELETE action.
      #
      # @param action_names [Symbol, Array<Symbol>] action name(s)
      # @param on [Symbol] :member or :collection
      # @return [void]
      #
      # @example
      #   member { delete :archive }
      def delete(action_names, on: nil)
        capture_actions(action_names, on:, method: :delete)
      end

      # @api public
      # Defines a reusable concern.
      #
      # @param concern_name [Symbol] concern name
      # @param callable [Proc] optional callable instead of block
      # @yield block with resource definitions
      # @yieldparam resource [Resource]
      # @return [void]
      #
      # @example instance_eval style
      #   concern :commentable do
      #     resources :comments
      #   end
      #
      #   resources :posts, concerns: [:commentable]
      #
      # @example yield style
      #   concern :commentable do |resource|
      #     resource.resources :comments
      #   end
      #
      #   resources :posts, concerns: [:commentable]
      def concern(concern_name, callable = nil, &block)
        callable ||= lambda do |resource, options|
          if block.arity.positive?
            yield(resource, options)
          else
            resource.instance_exec(options, &block)
          end
        end
        @concerns[concern_name] = callable
      end

      # @api public
      # Includes previously defined concerns.
      #
      # @param concern_names [Array<Symbol>] concern names to include
      # @param options [Hash] ({}) options passed to the concern
      # @return [void]
      #
      # @example
      #   resources :posts do
      #     concerns :commentable, :taggable
      #   end
      def concerns(*concern_names, **options)
        concern_names.flatten.each do |concern_name|
          callable = @concerns[concern_name]
          raise ConfigurationError, "No concern named :#{concern_name} was found" unless callable

          callable.call(self, options)
        end
      end

      private

      def collect_all_representation_classes
        representation_classes = []
        each_resource do |resource|
          representation_class = resource.representation_class
          representation_classes << representation_class if representation_class
        end
        representation_classes
      end

      def find_resource_by_block(&block)
        @resources.each_value do |resource|
          return resource if yield(resource)

          found = resource.find_resource(&block)
          return found if found
        end

        nil
      end

      def merged_options(options = {})
        (@current_options || {}).merge(options)
      end

      def build_resource(resource_name, options:, singular:)
        merged = merged_options(options)

        parent_name = @resource_stack.last
        parent_resource = parent_name ? find_resource(parent_name) : nil

        contract = merged.delete(:contract)

        resource = Resource.new(
          @api_class,
          name: resource_name,
          singular:,
          contract_class_name: contract ? contract_path_to_class_name(contract) : infer_contract_class_name(resource_name),
          **merged,
        )

        if parent_resource
          parent_resource.add_resource(resource)
        else
          add_resource(resource)
        end
      end

      def capture_actions(action_names, method:, on:)
        Array(action_names).each do |action_name|
          capture_action(action_name, method:, on:)
        end
      end

      def capture_action(action_name, method:, on:)
        resource_name = @resource_stack.last
        return unless resource_name

        resource = find_resource(resource_name)
        return unless resource

        if on && [:member, :collection].exclude?(on)
          raise ConfigurationError,
                ":on option must be either :member or :collection, got #{on.inspect}"
        end

        action_type = if @in_member_block || on == :member
                        :member
                      elsif @in_collection_block || on == :collection
                        :collection
                      end

        if action_type
          resource.add_action(action_name, method:, type: action_type)
        else
          raise ConfigurationError,
                "Action '#{action_name}' on resource '#{resource_name}' must be declared " \
                "within a member or collection block, or use the :on parameter.\n" \
                "Examples:\n" \
                "  member { #{method} :#{action_name} }\n" \
                "  #{method} :#{action_name}, on: :member\n" \
                "  collection { #{method} :#{action_name} }\n" \
                "  #{method} :#{action_name}, on: :collection"
        end
      end

      def infer_contract_class_name(resource_name)
        namespaces = @api_class.namespaces
        [*namespaces.map { |namespace| namespace.to_s.camelize }, "#{resource_name.to_s.singularize.camelize}Contract"].join('::')
      end

      def contract_path_to_class_name(contract_path)
        namespaces = @api_class.namespaces
        parts = if contract_path.start_with?('/')
                  contract_path[1..].split('/')
                else
                  namespaces + contract_path.split('/')
                end

        parts = parts.map { |part| part.to_s.camelize }
        parts[-1] = parts[-1].singularize

        "#{parts.join('::')}Contract"
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

      def build_actions
        actions = @crud_actions.map { |action_name| Action.new(action_name) }
        actions.concat(@custom_actions)
        actions.index_by(&:name)
      end
    end
  end
end
