# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Controller context', type: :integration do
  describe 'Default context' do
    it 'returns empty hash by default' do
      controller_class = Class.new(ApplicationController) do
        include Apiwork::Controller
      end

      controller = controller_class.new
      expect(controller.context).to eq({})
    end
  end

  describe 'Custom context' do
    it 'is overridable with custom data' do
      controller_class = Class.new(ApplicationController) do
        include Apiwork::Controller

        def context
          { current_user_id: 123, locale: :en }
        end
      end

      controller = controller_class.new
      expect(controller.context).to eq({ current_user_id: 123, locale: :en })
    end
  end

  describe 'Context inheritance' do
    it 'can be customized per controller subclass' do
      base_controller = Class.new(ApplicationController) do
        include Apiwork::Controller
      end

      custom_controller = Class.new(base_controller) do
        def context
          { custom: true }
        end
      end

      base = base_controller.new
      custom = custom_controller.new

      expect(base.context).to eq({})
      expect(custom.context).to eq({ custom: true })
    end
  end
end
