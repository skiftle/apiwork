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

    it 'accepts any hash structure' do
      controller_class = Class.new(ApplicationController) do
        include Apiwork::Controller

        def context
          {
            current_user: { id: 1, role: :admin },
            feature_flags: { new_ui: true },
            request_id: 'abc-123',
          }
        end
      end

      controller = controller_class.new
      expect(controller.context[:current_user]).to eq({ id: 1, role: :admin })
      expect(controller.context[:feature_flags]).to eq({ new_ui: true })
      expect(controller.context[:request_id]).to eq('abc-123')
    end
  end

  describe 'Context inheritance' do
    it 'is defined on Apiwork::Controller' do
      expect(Apiwork::Controller.instance_methods).to include(:context)
    end

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
