# frozen_string_literal: true

module Apiwork
  module Contract
    class Base
      include Abstractable

      class_attribute :action_definitions, instance_accessor: false
      class_attribute :imports, instance_accessor: false
      class_attribute :_identifier
      class_attribute :_schema_class

      attr_reader :action,
                  :body,
                  :issues,
                  :query

      def initialize(query:, body:, action:, coerce: true)
        result = RequestParser.new(self.class, action, coerce:).perform(query, body)
        @query = result.query
        @body = result.body
        @issues = result.issues
        @action = action.to_sym
      end

      def valid?
        issues.empty?
      end

      def invalid?
        issues.any?
      end

      class << self
        def inherited(subclass)
          super
          subclass.action_definitions = {}
          subclass.imports = {}
        end

        # DOCUMENTATION
        def identifier(value = nil)
          return _identifier if value.nil?

          self._identifier = value.to_s
        end

        # DOCUMENTATION
        def schema!
          return _schema_class if _schema_class

          schema_name = name.sub(/Contract$/, 'Schema')
          schema_class = schema_name.constantize

          self._schema_class = schema_class

          schema_class
        rescue NameError
          raise ArgumentError,
                "Expected to find #{schema_name} in app/schemas/. " \
                'Contract and Schema must follow convention: XContract ↔ XSchema'
        end

        def find_contract_for_schema(schema_class)
          return nil unless schema_class

          contract_name = schema_class.name.sub(/Schema$/, 'Contract')
          contract_name.constantize
        rescue NameError
          nil
        end

        def register_sti_variants(*variant_schema_classes)
          variant_schema_classes.each do |variant_class|
            unless variant_class.is_a?(Class) && variant_class < Apiwork::Schema::Base
              raise ArgumentError,
                    "Expected Schema class, got #{variant_class.inspect}. " \
                    'Use: register_sti_variants PersonSchema, CompanySchema'
            end

            variant_class.name
          end
        end

        def schema_class
          _schema_class
        end

        # DOCUMENTATION
        def schema?
          _schema_class.present?
        end

        def reset_build_state!
          self.action_definitions = {}
          self.imports = {}
        end

        def scope_prefix
          return _identifier if _identifier
          return schema_class.root_key.singular if schema_class

          return nil unless name

          name.demodulize.underscore.gsub(/_(contract|schema)$/, '')
        end

        def type(name, description: nil, example: nil, format: nil, deprecated: false,
                 schema_class: nil, &block)
          api_class.type(name, scope: self, description:, example:, format:, deprecated:,
                               schema_class:, &block)
        end

        def enum(name, values: nil, description: nil, example: nil, deprecated: false)
          api_class.enum(name, values:, scope: self, description:, example:, deprecated:)
        end

        def union(name, discriminator: nil, &block)
          api_class.union(name, scope: self, discriminator:, &block)
        end

        # DOCUMENTATION
        def import(contract_class, as:)
          unless contract_class.is_a?(Class)
            raise ArgumentError, "import must be a Class constant, got #{contract_class.class}. " \
                                 "Use: import UserContract, as: :user (not 'UserContract' or :user_contract)"
          end

          unless contract_class < Apiwork::Contract::Base
            raise ArgumentError, 'import must be a Contract class (subclass of Apiwork::Contract::Base), ' \
                                 "got #{contract_class}"
          end

          unless as.is_a?(Symbol)
            raise ArgumentError, "import alias must be a Symbol, got #{as.class}. " \
                                 'Use: import UserContract, as: :user'
          end

          imports[as] = contract_class
        end

        # DOCUMENTATION
        def action(action_name, replace: false, &block)
          action_name = action_name.to_sym

          action_definition = ActionDefinition.new(action_name:, contract_class: self, replace:)
          action_definition.instance_eval(&block) if block_given?

          action_definitions[action_name] = action_definition
        end

        def resolve_custom_type(type_name, visited: Set.new)
          raise ConfigurationError, "Circular import detected while resolving :#{type_name}" if visited.include?(self)

          result = api_class.resolve_type(type_name, scope: self)
          return result if result

          resolve_imported_type(type_name, visited: visited.dup.add(self))
        end

        def action_definition(action_name)
          api_class&.ensure_contract_built!(self)

          action_name = action_name.to_sym
          action_definitions[action_name]
        end

        # DOCUMENTATION
        def introspect(action: nil, locale: nil)
          Apiwork::Introspection.contract(self, action:, locale:)
        end

        def as_json
          introspect
        end

        def api_path
          return nil unless name

          namespace_parts = name.deconstantize.split('::')
          return nil if namespace_parts.empty?

          "/#{namespace_parts.map(&:underscore).join('/')}"
        end

        def api_class
          return @api_class if instance_variable_defined?(:@api_class)

          path = api_path
          return nil unless path

          Apiwork::API.find(path)
        end

        def parse_response(body, action)
          ResponseParser.new(self, action).perform(body)
        end

        def global_type(name, &block)
          api_class.type(name, scope: nil, &block)
        end

        def resolve_type(name)
          resolve_custom_type(name)
        end

        def resolve_enum(enum_name, visited: Set.new)
          return nil if visited.include?(self)

          result = api_class.resolve_enum(enum_name, scope: self)
          return result if result

          resolve_imported_enum(enum_name, visited: visited.dup.add(self))
        end

        def scoped_type_name(type_name)
          api_class.scoped_name(self, type_name)
        end

        def scoped_enum_name(enum_name)
          api_class.scoped_name(self, enum_name)
        end

        def define_action(action_name, &block)
          action_name = action_name.to_sym

          action_definition = action_definitions[action_name] ||= ActionDefinition.new(
            action_name:,
            contract_class: self
          )

          action_definition.instance_eval(&block) if block_given?
          action_definition
        end

        private

        def resolve_imported_type(type_name, visited:)
          imports.each do |import_alias, imported_contract|
            prefix = "#{import_alias}_"
            next unless type_name.to_s.start_with?(prefix)

            unprefixed_name = type_name.to_s.sub(prefix, '').to_sym
            result = imported_contract.resolve_custom_type(unprefixed_name, visited:)
            return result if result
          end

          nil
        end

        def resolve_imported_enum(enum_name, visited:)
          imports.each do |import_alias, imported_contract|
            prefix = "#{import_alias}_"
            next unless enum_name.to_s.start_with?(prefix)

            unprefixed_name = enum_name.to_s.sub(prefix, '').to_sym
            result = imported_contract.resolve_enum(unprefixed_name, visited:)
            return result if result
          end

          nil
        end
      end
    end
  end
end
