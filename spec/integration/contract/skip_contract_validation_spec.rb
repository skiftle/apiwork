# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'skip_contract_validation!', type: :integration do
  describe 'Controller with skip_contract_validation!' do
    let(:controller_class) do
      Class.new(ApplicationController) do
        include Apiwork::Controller

        skip_contract_validation!

        def ping
          render json: { status: 'ok' }
        end
      end
    end

    it 'skips contract validation for all actions' do
      controller = controller_class.new
      expect(controller._process_action_callbacks.map(&:filter)).not_to include(:validate_contract)
    end
  end

  describe 'Controller with skip_contract_validation! only: [:action]' do
    let(:controller_class) do
      Class.new(ApplicationController) do
        include Apiwork::Controller

        skip_contract_validation! only: [:health]

        def health
          render json: { status: 'healthy' }
        end

        def index
          render json: { items: [] }
        end
      end
    end

    it 'has validate_contract callback' do
      expect(controller_class._process_action_callbacks.map(&:filter)).to include(:validate_contract)
    end

    it 'configures skip for specified action' do
      callbacks = controller_class._process_action_callbacks.select { |cb| cb.filter == :validate_contract }
      expect(callbacks).not_to be_empty
    end
  end

  describe 'Controller with skip_contract_validation! except: [:action]' do
    let(:controller_class) do
      Class.new(ApplicationController) do
        include Apiwork::Controller

        skip_contract_validation! except: [:create]

        def create
          render json: { created: true }
        end

        def legacy
          render json: { legacy: true }
        end
      end
    end

    it 'keeps validation for non-excepted actions' do
      expect(controller_class._process_action_callbacks.map(&:filter)).to include(:validate_contract)
    end
  end

  describe 'skip_contract_validation! is class method' do
    it 'is available on controllers including Apiwork::Controller' do
      expect(Apiwork::Controller.instance_methods).not_to include(:skip_contract_validation!)
    end

    it 'responds to skip_contract_validation! as class method' do
      controller_class = Class.new(ApplicationController) do
        include Apiwork::Controller
      end

      expect(controller_class).to respond_to(:skip_contract_validation!)
    end
  end
end
