# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Operation
        # @api public
        # Base class for capability Operation phase.
        #
        # Operation phase runs on each request.
        # Use it to transform data at runtime.
        class Base
          # @api public
          # The data for this operation.
          #
          # @return [Object]
          attr_reader :data

          # @api public
          # The options for this operation.
          #
          # @return [Configuration]
          attr_reader :options

          # @api public
          # The request for this operation.
          #
          # @return [Request]
          attr_reader :request

          # @api public
          # The representation class for this operation.
          #
          # @return [Class<Representation::Base>]
          attr_reader :representation_class

          class << self
            # @api public
            # The target for this operation.
            #
            # @param value [Symbol, nil] (nil) [:collection, :member]
            #   The target type.
            # @return [Symbol, nil]
            def target(value = nil)
              @target = value if value
              @target
            end

            # @api public
            # Defines metadata shape for this operation.
            #
            # Pass a block or a {MetadataShape} subclass.
            # Blocks are evaluated via instance_exec, providing access to
            # type DSL methods and capability options.
            #
            # @param klass [Class<MetadataShape>, nil] (nil)
            #   The metadata shape class.
            # @yield block that defines metadata structure
            # @return [Class<MetadataShape>, nil]
            #
            # @example With block
            #   metadata_shape do
            #     reference(:pagination, to: :offset_pagination)
            #   end
            #
            # @example With class
            #   metadata_shape PaginationShape
            def metadata_shape(klass = nil, &block)
              if klass
                @metadata_shape_class = klass
              elsif block
                @metadata_shape_class = wrap_metadata_shape_block(block)
              end
              @metadata_shape_class
            end

            private

            def wrap_metadata_shape_block(callable)
              Class.new(MetadataShape) do
                define_singleton_method(:callable) { callable }

                def apply
                  block = self.class.callable
                  block.arity.positive? ? block.call(self) : instance_exec(&block)
                end
              end
            end
          end

          def initialize(data, representation_class, options, request, translation_context: {})
            @data = data
            @representation_class = representation_class
            @options = options
            @request = request
            @translation_context = translation_context
          end

          # @api public
          # Applies this operation to the data.
          #
          # Override this method to implement transformation logic.
          # Return `nil` if no changes are made.
          #
          # @return [Result, nil]
          def apply
            raise NotImplementedError
          end

          # @api public
          # Creates a result object.
          #
          # @param data [Object, nil] (nil)
          #   The transformed data.
          # @param includes [Array, nil] (nil)
          #   The associations to preload.
          # @param metadata [Hash, nil] (nil)
          #   The metadata to add to response.
          # @param serialize_options [Hash, nil] (nil)
          #   The options for serialization.
          # @return [Result]
          def result(data: nil, includes: nil, metadata: nil, serialize_options: nil)
            Result.new(
              data:,
              includes:,
              metadata:,
              serialize_options:,
            )
          end

          # @api public
          # Translates a key using the adapter's i18n convention.
          #
          # Lookup order:
          # 1. `apiwork.apis.<locale_key>.adapters.<adapter_name>.capabilities.<capability_name>.<segments>`
          # 2. `apiwork.adapters.<adapter_name>.capabilities.<capability_name>.<segments>`
          # 3. Provided default
          #
          # @param segments [Array<Symbol, String>]
          #   The key path segments.
          # @param default [String, nil] (nil)
          #   The fallback value if no translation found.
          # @return [String, nil]
          #
          # @example
          #   translate(:domain_issues, :invalid, :detail)
          #   # Tries: apiwork.apis.billing.adapters.standard.capabilities.writing.domain_issues.invalid.detail
          #   # Falls back to: apiwork.adapters.standard.capabilities.writing.domain_issues.invalid.detail
          def translate(*segments, default: nil)
            adapter_name = @translation_context[:adapter_name]
            capability_name = @translation_context[:capability_name]
            locale_key = @translation_context[:locale_key]
            key_suffix = segments.join('.')

            if locale_key
              api_key = :"apiwork.apis.#{locale_key}.adapters.#{adapter_name}.capabilities.#{capability_name}.#{key_suffix}"
              result = I18n.translate(api_key, default: nil)
              return result if result
            end

            adapter_key = :"apiwork.adapters.#{adapter_name}.capabilities.#{capability_name}.#{key_suffix}"
            result = I18n.translate(adapter_key, default: nil)
            return result if result

            default
          end
        end
      end
    end
  end
end
