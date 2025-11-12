# frozen_string_literal: true

require 'ostruct'

module ApiworkHelpers
  # Mock controller with Resourceable concern
  def mock_controller(action_name: :index, request_method: :get, params: {})
    controller_class = Class.new(ApplicationController) do
      include Apiwork::Controller::Concern

      def controller_name
        'test'
      end

      def action_name
        @action_name ||= :index
      end

      def action_name=(name)
        @action_name = name
      end
    end

    controller = controller_class.new
    controller.action_name = action_name

    # Mock class name for controller
    controller_class = Class.new do
      def self.name
        'Api::V1::TestController'
      end
    end

    # Mock request
    request = mock_request(method: request_method)

    # Mock params
    controller_params = ActionController::Parameters.new(params)

    # Mock response
    response = double('Response')
    allow(response).to receive(:status=)
    allow(controller).to receive_messages(class: controller_class, request: request, params: controller_params,
                                          response: response)

    # Mock render method
    allow(controller).to receive(:render) do |options|
      controller.instance_variable_set(:@rendered_data, options)
    end

    controller
  end

  # Mock request object
  def mock_request(method: :get)
    double('Request',
           get?: method == :get,
           post?: method == :post,
           patch?: method == :patch,
           put?: method == :put,
           delete?: method == :delete,
           variant: [],
           query_parameters: {})
  end

  # Mock params
  def mock_params(data = {})
    ActionController::Parameters.new(data)
  end

  # Test resource class
  def test_resource_class(_name = 'TestResource', &block)
    Class.new(Apiwork::Schema::Base) do
      self.model_class = Class.new do
        def self.column_names
          %w[id name email age created_at updated_at]
        end

        def self.columns_hash
          {
            'id' => OpenStruct.new(type: :integer, null: false),
            'name' => OpenStruct.new(type: :string, null: false),
            'email' => OpenStruct.new(type: :string, null: true),
            'age' => OpenStruct.new(type: :integer, null: true),
            'created_at' => OpenStruct.new(type: :datetime, null: false),
            'updated_at' => OpenStruct.new(type: :datetime, null: false)
          }
        end

        def self.type_for_attribute(name)
          OpenStruct.new(type: columns_hash[name]&.type || :string)
        end

        def self.defined_enums
          {}
        end

        def self.validators_on(_attr_name)
          []
        end

        def self.name
          'TestModel'
        end

        def self.model_name
          OpenStruct.new(element: 'test_model')
        end

        def self.reflect_on_association(_name)
          nil # No real associations in mock
        end
      end

      class_eval(&block) if block_given?
    end
  end

  # Test Contract class (replaces test_input_class)
  def test_contract_class(name = 'TestContract', &block)
    Class.new(Apiwork::Contract::Base) do
      define_singleton_method(:name) { name }
      class_eval(&block) if block_given?
    end
  end

  # Test model instance
  def test_model_instance(attributes = {})
    double('ModelInstance',
           id: attributes[:id] || SecureRandom.uuid,
           name: attributes[:name] || 'Test Name',
           email: attributes[:email] || 'test@example.com',
           created_at: attributes[:created_at] || Time.current,
           updated_at: attributes[:updated_at] || Time.current,
           **attributes)
  end

  # Mock Current context
  def mock_current(user: nil, session: nil, membership: nil)
    allow(Current).to receive_messages(user: user, session: session, membership: membership)
  end

  # Test context hash
  def test_context(user: nil, session: nil, membership: nil)
    {
      user: user,
      session: session,
      membership: membership
    }.compact
  end

  # Mock ActiveRecord::Relation
  def mock_relation(records = [])
    # Create a mock model class that responds to model_name
    model_class = Class.new do
      def self.model_name
        OpenStruct.new(element: 'test_model')
      end
    end

    relation = double('ActiveRecord::Relation')
    allow(relation).to receive(:each).and_yield(*records)
    allow(relation).to receive_messages(map: records.map { |r|
      r
    }, to_a: records, count: records.length, empty?: records.empty?, present?: !records.empty?, klass: model_class)
    relation
  end

  # Mock includes for N+1 prevention
  def mock_includes(relation, associations)
    allow(relation).to receive(:includes).with(associations).and_return(relation)
    relation
  end

  # Test pagination metadata
  def test_pagination_metadata(page: 1, per_page: 25, total: 100)
    {
      page: page,
      per_page: per_page,
      total: total,
      total_pages: (total.to_f / per_page).ceil
    }
  end

  # Mock errors object
  def mock_errors(messages = {})
    errors = double('Errors',
                    full_messages: messages.values.flatten,
                    messages: messages,
                    any?: messages.any? { |_, msgs| msgs.any? })

    # Mock the map method for error iteration
    allow(errors).to receive(:map).and_return(messages.map do |attr, msgs|
      msgs.map do |msg|
        double('Error',
               attribute: attr,
               message: msg,
               to_h: { attribute: attr, message: msg })
      end
    end.flatten)

    errors
  end
end

RSpec.configure do |config|
  config.include ApiworkHelpers, type: :apiwork
end
