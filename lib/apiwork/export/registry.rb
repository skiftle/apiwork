# frozen_string_literal: true

module Apiwork
  module Export
    class Registry < Apiwork::Registry
      class << self
        def register(export_class)
          raise ArgumentError, 'Export must inherit from Apiwork::Export::Base' unless export_class < Base
          raise ArgumentError, "Export #{export_class} must define an export_name" unless export_class.export_name

          store[export_class.export_name] = export_class
        end

        def all
          keys
        end
      end
    end
  end
end
