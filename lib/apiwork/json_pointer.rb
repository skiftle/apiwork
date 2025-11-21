# frozen_string_literal: true

module Apiwork
  module JSONPointer
    module_function

    def build(*path)
      return '' if path.empty?

      "/#{path.map { |component| escape_component(component.to_s) }.join('/')}"
    end

    def escape_component(component)
      component.gsub('~', '~0').gsub('/', '~1')
    end
  end
end
