# frozen_string_literal: true

module Apiwork
  # @api private
  class JSONPointer
    def initialize(*path)
      @path = path
    end

    def to_s
      return '' if @path.empty?

      "/#{@path.map { |component| escape(component.to_s) }.join('/')}"
    end

    private

    def escape(component)
      component.gsub('~', '~0').gsub('/', '~1')
    end
  end
end
