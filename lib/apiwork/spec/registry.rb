# frozen_string_literal: true

module Apiwork
  module Spec
    class Registry < Apiwork::Registry
      class << self
        def register(spec_class)
          raise ArgumentError, 'Spec must inherit from Apiwork::Spec::Base' unless spec_class < Base
          raise ArgumentError, "Spec #{spec_class} must define a spec_name" unless spec_class.spec_name

          store[spec_class.spec_name] = spec_class
        end

        def find(name)
          fetch(name)
        end

        def all
          keys
        end
      end
    end
  end
end
