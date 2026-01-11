# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Controller#context', type: :integration do
  # This tests the Controller#context method which provides context data
  # to schemas during serialization. The context method is meant to be
  # overridden in application controllers.

  describe 'Default context' do
    it 'returns empty hash by default' do
      controller_class = Class.new(ApplicationController) do
        include Apiwork::Controller
      end

      controller = controller_class.new
      expect(controller.context).to eq({})
    end
  end

  describe 'Context method API' do
    it 'context method is public and overridable' do
      controller_class = Class.new(ApplicationController) do
        include Apiwork::Controller

        def context
          { current_user_id: 123, locale: :en }
        end
      end

      controller = controller_class.new
      expect(controller.context).to eq({ current_user_id: 123, locale: :en })
    end

    it 'context can return any hash' do
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

  describe 'Context documentation' do
    it 'Controller#context is documented as public API' do
      # Verify that Apiwork::Controller has the context method
      expect(Apiwork::Controller.instance_methods).to include(:context)
    end

    it 'context method can be customized per controller' do
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

  # NOTE: Testing that context is actually passed through to schemas
  # would require setting up a full request flow. The current tests
  # verify the API contract of the context method itself.
end
