# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Concern
        def concern(name, callable = nil, &block)
          callable ||= ->(recorder, options) { recorder.instance_exec(options, &block) }
          @concerns[name] = callable
        end

        def concerns(*names, **options)
          names.flatten.each do |name|
            callable = @concerns[name]
            raise ConfigurationError, "No concern named :#{name} was found" unless callable

            callable.call(self, options)
          end
        end
      end
    end
  end
end
