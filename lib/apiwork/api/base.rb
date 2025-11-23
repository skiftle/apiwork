# frozen_string_literal: true

module Apiwork
  module API
    class Base
      class << self
        attr_reader :metadata,
                    :mount_path,
                    :namespaces,
                    :recorder,
                    :specs

        def mount(path)
          @mount_path = path
          @specs = {}

          @namespaces = path == '/' ? [:root] : path.split('/').reject(&:empty?).map(&:to_sym)

          @metadata = Metadata.new(path)
          @recorder = Recorder.new(@metadata, @namespaces)

          Registry.register(self)

          Descriptor.register_core(self)

          @configuration = {}
        end

        def spec(type, path: nil)
          unless Generator::Registry.registered?(type)
            available = Generator::Registry.all.join(', ')
            raise ConfigurationError,
                  "Unknown spec generator: :#{type}. " \
                  "Available generators: #{available}"
          end

          @specs ||= {}

          path ||= "/.spec/#{type}"

          @specs[type] = path
        end

        def specs?
          @specs&.any?
        end

        def error_codes(*codes)
          @metadata.error_codes = codes.flatten.map(&:to_i).uniq.sort
        end

        def configure(&block)
          return unless block

          builder = Configuration::Builder.new(@configuration)
          builder.instance_eval(&block)
        end

        def configuration
          @configuration ||= {}
        end

        def adapter
          @adapter ||= begin
            adapter_name = configuration[:adapter] || :standard
            Adapter.resolve(adapter_name).new
          end
        end

        def type(name, description: nil, example: nil, format: nil, deprecated: false, &block)
          Descriptor.define_type(
            name,
            api_class: self,
            description: description,
            example: example,
            format: format,
            deprecated: deprecated,
            &block
          )
        end

        def enum(name, values:, description: nil, example: nil, deprecated: false)
          Descriptor.define_enum(
            name,
            values: values,
            api_class: self,
            description: description,
            example: example,
            deprecated: deprecated
          )
        end

        def union(name, &block)
          Descriptor.define_union(name, api_class: self, &block)
        end

        def info(&block)
          builder = Info::Builder.new
          builder.instance_eval(&block)
          @metadata.info = builder.info
        end

        def resources(name, **options, &block)
          @recorder.resources(name, **options, &block)
        end

        def resource(name, **options, &block)
          @recorder.resource(name, **options, &block)
        end

        def concern(name, &block)
          @recorder.concern(name, &block)
        end

        def with_options(options = {}, &block)
          @recorder.with_options(options, &block)
        end

        def introspect
          @introspect ||= Apiwork::Introspection.api(self)
        end

        def as_json
          introspect
        end
      end
    end
  end
end
