# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Introspection', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }

  describe 'API introspection' do
    it 'returns introspection with base path' do
      expect(introspection.base_path).to eq('/api/v1')
    end

    it 'includes API title' do
      expect(introspection.info.to_h[:title]).to eq('Billing API')
    end

    it 'includes all top-level resources' do
      resource_keys = introspection.resources.keys

      expect(resource_keys).to include(:invoices)
      expect(resource_keys).to include(:customers)
      expect(resource_keys).to include(:payments)
      expect(resource_keys).to include(:services)
      expect(resource_keys).to include(:activities)
      expect(resource_keys).to include(:receipts)
      expect(resource_keys).to include(:profile)
    end

    it 'includes types for resources and shared objects' do
      type_keys = introspection.types.keys

      expect(type_keys).to include(:error_detail, :pagination_params, :invoice, :payment, :customer)
    end

    it 'includes enums from model definitions' do
      enum_keys = introspection.enums.keys

      expect(enum_keys).to include(:invoice_status, :layer, :payment_method, :payment_status)
    end

    it 'includes error codes' do
      error_code_keys = introspection.error_codes.keys

      expect(error_code_keys).to include(:bad_request, :internal_server_error, :not_found, :unprocessable_entity)
    end

    it 'serializes to hash with to_h' do
      hash = introspection.to_h

      expect(hash).to have_key(:base_path)
      expect(hash).to have_key(:resources)
      expect(hash).to have_key(:types)
      expect(hash).to have_key(:enums)
      expect(hash).to have_key(:error_codes)
    end
  end

  describe 'Resource introspection' do
    let(:invoices_resource) { introspection.resources[:invoices] }

    it 'includes identifier and path' do
      expect(invoices_resource.identifier).to eq('invoices')
      expect(invoices_resource.path).to eq('invoices')
    end

    it 'includes all invoice actions including custom ones' do
      action_keys = invoices_resource.actions.keys

      expect(action_keys).to include(:index, :show, :create, :update, :destroy)
      expect(action_keys).to include(:send_invoice, :void, :search, :bulk_create)
    end

    it 'includes nested items resource' do
      expect(invoices_resource.resources).to have_key(:items)
    end

    it 'serializes resource to hash' do
      hash = invoices_resource.to_h

      expect(hash).to have_key(:identifier)
      expect(hash).to have_key(:path)
      expect(hash).to have_key(:actions)
      expect(hash).to have_key(:resources)
    end
  end

  describe 'Action introspection' do
    let(:invoices_resource) { introspection.resources[:invoices] }
    let(:show_action) { invoices_resource.actions[:show] }
    let(:create_action) { invoices_resource.actions[:create] }
    let(:destroy_action) { invoices_resource.actions[:destroy] }
    let(:index_action) { invoices_resource.actions[:index] }

    it 'includes HTTP method' do
      expect(show_action.method).to eq(:get)
      expect(create_action.method).to eq(:post)
      expect(destroy_action.method).to eq(:delete)
    end

    it 'includes action path' do
      expect(show_action.path).to include('invoices')
    end

    it 'includes summary and description when provided' do
      expect(show_action.summary).to eq('Get an invoice')
      expect(index_action.description).to eq('Returns a paginated list of all invoices')
    end

    it 'includes deprecated status' do
      expect(show_action.deprecated?).to be(false)
      expect(destroy_action.deprecated?).to be(true)
    end

    it 'includes custom operation_id when specified' do
      expect(destroy_action.operation_id).to eq('deleteInvoice')
    end

    it 'includes raises error codes' do
      expect(show_action.raises).to include(:not_found, :forbidden)
      expect(create_action.raises).to include(:unprocessable_entity)
    end

    it 'includes tags when specified' do
      expect(index_action.tags).to include(:invoices, :public)
    end

    it 'includes request with body for create and query for index' do
      expect(create_action.request.body?).to be(true)
      expect(index_action.request.query?).to be(true)
    end

    it 'includes response definition' do
      expect(show_action.response.to_h).to have_key(:body)
      expect(show_action.response.to_h).to have_key(:no_content)
    end

    it 'serializes action to hash' do
      hash = show_action.to_h

      expect(hash).to have_key(:path)
      expect(hash).to have_key(:method)
      expect(hash).to have_key(:raises)
      expect(hash).to have_key(:summary)
    end
  end

  describe 'Enum introspection' do
    it 'includes layer values' do
      expect(introspection.enums[:layer].values).to contain_exactly('contract', 'domain', 'http')
    end

    it 'includes invoice_status values' do
      expect(introspection.enums[:invoice_status].values).to contain_exactly('draft', 'overdue', 'paid', 'sent', 'void')
    end

    it 'includes payment_method values' do
      expect(introspection.enums[:payment_method].values).to contain_exactly('bank_transfer', 'cash', 'credit_card')
    end

    it 'includes payment_status values' do
      expect(introspection.enums[:payment_status].values).to contain_exactly('completed', 'failed', 'pending', 'refunded')
    end

    it 'serializes enum to hash' do
      expect(introspection.enums[:invoice_status].to_h).to have_key(:values)
    end
  end

  describe 'Type introspection' do
    it 'includes error_detail as object type with shape and params' do
      error_type = introspection.types[:error_detail]

      expect(error_type.type).to eq(:object)
      expect(error_type.object?).to be(true)
      expect(error_type.shape.keys).to include(:code, :message, :field)
      expect(error_type.shape[:code].type).to eq(:string)
      expect(error_type.shape[:code].scalar?).to be(true)
    end

    it 'serializes type to hash' do
      hash = introspection.types[:error_detail].to_h

      expect(hash).to have_key(:type)
      expect(hash).to have_key(:shape)
    end
  end

  describe 'Error code introspection' do
    it 'includes status codes and serializes to hash' do
      expect(introspection.error_codes[:bad_request].status).to eq(400)
      expect(introspection.error_codes[:not_found].status).to eq(404)
      expect(introspection.error_codes[:bad_request].to_h).to have_key(:status)
    end
  end
end
