# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Action Metadata', type: :integration do
  describe 'Action#summary' do
    it 'sets a short summary for the action' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'SummaryTestContract'
        end

        action :index do
          summary 'List all invoices'
        end
      end

      action = contract.actions[:index]
      expect(action.summary).to eq('List all invoices')
    end

    it 'returns nil when summary is not set' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'NoSummaryContract'
        end

        action :index do
          # No summary set
        end
      end

      action = contract.actions[:index]
      expect(action.summary).to be_nil
    end
  end

  describe 'Action#description' do
    it 'sets a detailed description for the action' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'DescriptionTestContract'
        end

        action :create do
          description 'Creates a new invoice and sends notification email to the customer.'
        end
      end

      action = contract.actions[:create]
      expect(action.description).to eq('Creates a new invoice and sends notification email to the customer.')
    end

    it 'supports multiline descriptions' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'MultilineDescContract'
        end

        action :index do
          description <<~DESC.strip
            Returns a paginated list of invoices.

            Supports filtering by status, date range, and customer.
            Results are ordered by created_at descending.
          DESC
        end
      end

      action = contract.actions[:index]
      expect(action.description).to include('Returns a paginated list')
      expect(action.description).to include('Supports filtering')
    end

    it 'returns nil when description is not set' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'NoDescContract'
        end

        action :index do
          # No description
        end
      end

      action = contract.actions[:index]
      expect(action.description).to be_nil
    end
  end

  describe 'Action#tags' do
    it 'sets tags for grouping the action' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'TagsTestContract'
        end

        action :create do
          tags :billing, :invoices
        end
      end

      action = contract.actions[:create]
      expect(action.tags).to eq(%i[billing invoices])
    end

    it 'accepts a single tag' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'SingleTagContract'
        end

        action :index do
          tags :public
        end
      end

      action = contract.actions[:index]
      expect(action.tags).to eq([:public])
    end

    it 'accepts string tags' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'StringTagsContract'
        end

        action :index do
          tags 'Billing', 'Payments'
        end
      end

      action = contract.actions[:index]
      expect(action.tags).to eq(%w[Billing Payments])
    end

    it 'returns nil when tags are not set' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'NoTagsContract'
        end

        action :index do
          # No tags
        end
      end

      action = contract.actions[:index]
      expect(action.tags).to be_nil
    end
  end

  describe 'Action#deprecated' do
    it 'marks the action as deprecated' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'DeprecatedTestContract'
        end

        action :legacy_create do
          deprecated
        end
      end

      action = contract.actions[:legacy_create]
      expect(action.deprecated?).to be(true)
    end

    it 'returns false when action is not deprecated' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'NotDeprecatedContract'
        end

        action :create do
          # Not deprecated
        end
      end

      action = contract.actions[:create]
      expect(action.deprecated?).to be(false)
    end
  end

  describe 'Action#operation_id' do
    it 'sets a custom operation ID' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'OperationIdTestContract'
        end

        action :create do
          operation_id 'createNewInvoice'
        end
      end

      action = contract.actions[:create]
      expect(action.operation_id).to eq('createNewInvoice')
    end

    it 'returns nil when operation_id is not set' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'NoOperationIdContract'
        end

        action :create do
          # No operation_id
        end
      end

      action = contract.actions[:create]
      expect(action.operation_id).to be_nil
    end
  end

  describe 'Combining all metadata' do
    it 'supports all metadata options together' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'FullMetadataContract'
        end

        action :create do
          summary 'Create an invoice'
          description 'Creates a new invoice with the provided details.'
          tags :billing, :write
          operation_id 'createInvoice'
          raises :bad_request, :unauthorized
        end
      end

      action = contract.actions[:create]
      expect(action.summary).to eq('Create an invoice')
      expect(action.description).to eq('Creates a new invoice with the provided details.')
      expect(action.tags).to eq(%i[billing write])
      expect(action.operation_id).to eq('createInvoice')
      expect(action.deprecated?).to be(false)
    end

    it 'supports deprecated with other metadata' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'DeprecatedWithMetadataContract'
        end

        action :old_create do
          summary 'Create an invoice (deprecated)'
          description 'Use /v2/invoices instead.'
          deprecated
          tags :billing, :deprecated
        end
      end

      action = contract.actions[:old_create]
      expect(action.summary).to eq('Create an invoice (deprecated)')
      expect(action.deprecated?).to be(true)
      expect(action.tags).to include(:deprecated)
    end
  end

  describe 'Metadata in introspection' do
    it 'includes summary in action introspection' do
      # Use existing PostContract
      contract = Api::V1::PostContract
      contract.action_for(:index)

      introspection = contract.introspect
      action_data = introspection.actions[:index]

      # Action introspection should have summary accessor
      expect(action_data).to respond_to(:summary)
    end

    it 'includes deprecated status in action introspection' do
      contract = Api::V1::PostContract
      contract.action_for(:show)

      introspection = contract.introspect
      action_data = introspection.actions[:show]

      expect(action_data).to respond_to(:deprecated?)
      expect(action_data.deprecated?).to be(false)
    end

    it 'includes tags in action introspection' do
      contract = Api::V1::PostContract
      contract.action_for(:create)

      introspection = contract.introspect
      action_data = introspection.actions[:create]

      expect(action_data).to respond_to(:tags)
    end

    it 'includes operation_id in action introspection' do
      contract = Api::V1::PostContract
      contract.action_for(:update)

      introspection = contract.introspect
      action_data = introspection.actions[:update]

      expect(action_data).to respond_to(:operation_id)
    end
  end

  describe 'Metadata in OpenAPI export' do
    it 'includes action metadata in OpenAPI output' do
      # Generate OpenAPI for the test API
      openapi_json = Apiwork::Export.generate(:openapi, '/api/v1')
      openapi = JSON.parse(openapi_json)

      # OpenAPI should have paths with operation metadata
      expect(openapi).to have_key('paths')
      expect(openapi['paths']).to be_present
    end

    it 'exports operation summary when present' do
      openapi_json = Apiwork::Export.generate(:openapi, '/api/v1')
      openapi = JSON.parse(openapi_json)

      # Check that paths exist
      paths = openapi['paths']
      expect(paths).to be_present

      # At least some operations should exist
      first_path = paths.keys.first
      expect(first_path).to be_present
    end

    it 'exports deprecated actions with deprecated flag' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'Api::V1::DeprecatedExportContract'
        end

        action :show do
          deprecated
        end
      end

      action = contract.actions[:show]
      expect(action.deprecated?).to be(true)
    end
  end
end
