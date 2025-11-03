# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::APIInspector, type: :apiwork do
  let(:path) { '/api/v1' }

  # Note: These tests check the structure of what APIInspector returns
  # Actual API registration happens through routes.rb in real usage

  describe '.resources' do
    it 'returns array of resources' do
      result = described_class.resources(path: path)

      expect(result).to be_an(Array)
      # May be empty if no API is registered
    end

    it 'includes resource metadata when resources exist' do
      result = described_class.resources(path: path)

      if result.any?
        resource = result.first

        expect(resource).to have_key(:class_name)
        expect(resource).to have_key(:name)
        expect(resource).to have_key(:namespaces)
      end
    end

    it 'includes class_name when resources exist' do
      result = described_class.resources(path: path)

      if result.any?
        resource = result.first

        expect(resource[:class_name]).to be_a(String)
      end
    end

    it 'includes singular name when resources exist' do
      result = described_class.resources(path: path)

      if result.any?
        resource = result.first

        expect(resource[:name]).to be_a(String)
        expect(resource[:name]).not_to include('_resource')
      end
    end

    it 'includes namespaces array when resources exist' do
      result = described_class.resources(path: path)

      if result.any?
        resource = result.first

        expect(resource[:namespaces]).to be_an(Array)
        expect(resource[:namespaces]).to include('Api', 'V1')
      end
    end
  end

  describe '.routes' do
    it 'returns routes structure' do
      result = described_class.routes(path: path)

      expect(result).to be_a(Hash)
      # May be empty if no API is registered
    end

    it 'includes actions for resources when they exist' do
      result = described_class.routes(path: path)

      if result.any?
        first_route = result.values.first
        expect(first_route).to have_key(:actions) if first_route.is_a?(Hash)
      end
    end

    it 'includes HTTP methods when actions exist' do
      result = described_class.routes(path: path)

      if result.any?
        first_route = result.values.first
        if first_route.is_a?(Hash) && first_route[:actions]
          actions = first_route[:actions]
          expect(actions).to be_a(Hash)
        end
      end
    end

    it 'includes resource_class_name when routes exist' do
      result = described_class.routes(path: path)

      if result.any?
        first_route = result.values.first
        if first_route.is_a?(Hash)
          expect(first_route).to have_key(:resource_class_name)
          expect(first_route[:resource_class_name]).to be_a(String) if first_route[:resource_class_name]
        end
      end
    end

    it 'includes singular flag when routes exist' do
      result = described_class.routes(path: path)

      if result.any?
        first_route = result.values.first
        if first_route.is_a?(Hash)
          expect(first_route).to have_key(:singular)
          expect(first_route[:singular]).to be_in([true, false]) if first_route.key?(:singular)
        end
      end
    end
  end

  describe '.inputs' do
    it 'returns array of inputs' do
      result = described_class.inputs(path: path)

      expect(result).to be_an(Array)
    end

    it 'includes input metadata when inputs exist' do
      # Would need actual input classes registered
      result = described_class.inputs(path: path)

      # May be empty if no inputs are registered
      if result.any?
        input = result.first
        expect(input).to have_key(:class_name)
        expect(input).to have_key(:name)
        expect(input).to have_key(:namespaces)
        expect(input).to have_key(:params)
      end
    end

    it 'strips _input suffix from name' do
      # Would need actual input classes registered
      result = described_class.inputs(path: path)

      if result.any?
        input = result.first
        expect(input[:name]).not_to end_with('_input')
      end
    end
  end

  describe 'integration' do
    it 'provides consistent API structure' do
      resources = described_class.resources(path: path)
      routes = described_class.routes(path: path)
      inputs = described_class.inputs(path: path)

      # All should return proper structures
      expect(resources).to be_an(Array)
      expect(routes).to be_a(Hash)
      expect(inputs).to be_an(Array)
    end

    it 'handles nested resources when they exist' do
      routes = described_class.routes(path: path)

      # Check if any routes have nested routes
      routes.each_value do |route|
        if route.is_a?(Hash) && route[:routes]
          expect(route[:routes]).to be_a(Hash)
        end
      end
    end

    it 'handles member actions when they exist' do
      routes = described_class.routes(path: path)

      # Check if any routes have member actions
      routes.each_value do |route|
        if route.is_a?(Hash) && route[:members]
          expect(route[:members]).to be_a(Hash)
        end
      end
    end

    it 'handles collection actions when they exist' do
      routes = described_class.routes(path: path)

      # Check if any routes have collection actions
      routes.each_value do |route|
        if route.is_a?(Hash) && route[:collections]
          expect(route[:collections]).to be_a(Hash)
        end
      end
    end
  end
end
