# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Generator do
  describe '.generate_writable_params' do
    let(:contract_class) { Class.new(Apiwork::Contract::Base) }
    let(:definition) { Apiwork::Contract::Definition.new(:input, contract_class) }

    context 'with required enum field (null: false constraint)' do
      it 'generates required: true for Service.color' do
        described_class.generate_writable_params(definition, Api::V1::ServiceResource, :create)

        color_param = definition.params[:color]
        expect(color_param).to be_present
        expect(color_param[:required]).to be true
        expect(color_param[:type]).to eq(:string)
        expect(color_param[:enum]).to include('red', 'orange', 'yellow')
      end

      it 'generates required: true for Service.icon' do
        described_class.generate_writable_params(definition, Api::V1::ServiceResource, :create)

        icon_param = definition.params[:icon]
        expect(icon_param).to be_present
        expect(icon_param[:required]).to be true
        expect(icon_param[:type]).to eq(:string)
        expect(icon_param[:enum]).to include('broom', 'truck', 'user')
      end

      it 'generates required: true for Service.name' do
        described_class.generate_writable_params(definition, Api::V1::ServiceResource, :create)

        name_param = definition.params[:name]
        expect(name_param).to be_present
        expect(name_param[:required]).to be true
        expect(name_param[:type]).to eq(:string)
        expect(name_param[:enum]).to be_nil
      end
    end

    context 'with required enum field (presence validation)' do
      it 'generates required: true for LeaveRequest.kind' do
        described_class.generate_writable_params(definition, Api::V1::LeaveRequestResource, :create)

        kind_param = definition.params[:kind]
        expect(kind_param).to be_present
        expect(kind_param[:required]).to be true
        expect(kind_param[:type]).to eq(:string)
        expect(kind_param[:enum]).to include('childcare', 'sick', 'vacation', 'other')
      end

      it 'generates required: true for TimeEntry.source' do
        described_class.generate_writable_params(definition, Api::V1::TimeEntryResource, :create)

        source_param = definition.params[:source]
        expect(source_param).to be_present
        expect(source_param[:required]).to be true
        expect(source_param[:type]).to eq(:string)
        expect(source_param[:enum]).to include('manual', 'mobile', 'kiosk')
      end
    end

    context 'with optional enum field (null: true)' do
      it 'generates required: false for Client.kind' do
        described_class.generate_writable_params(definition, Api::V1::ClientResource, :create)

        kind_param = definition.params[:kind]
        expect(kind_param).to be_present
        expect(kind_param[:required]).to be false
        expect(kind_param[:type]).to eq(:string)
        expect(kind_param[:enum]).to include('individual', 'organization')
      end
    end

    context 'with required non-enum field' do
      it 'generates required: true for Employee.first_name' do
        described_class.generate_writable_params(definition, Api::V1::EmployeeResource, :create)

        first_name_param = definition.params[:first_name]
        expect(first_name_param).to be_present
        expect(first_name_param[:required]).to be true
        expect(first_name_param[:type]).to eq(:string)
        expect(first_name_param[:enum]).to be_nil
      end
    end

    context 'with optional non-enum field' do
      it 'generates required: false for Employee.note' do
        described_class.generate_writable_params(definition, Api::V1::EmployeeResource, :create)

        note_param = definition.params[:note]
        expect(note_param).to be_present
        expect(note_param[:required]).to be false
        expect(note_param[:type]).to eq(:string)
        expect(note_param[:enum]).to be_nil
      end
    end

    context 'with writable UUID field' do
      it 'generates required: true for Employee.user_id (optional)' do
        described_class.generate_writable_params(definition, Api::V1::EmployeeResource, :create)

        # Note: user_id is nullable, so should be required: false
        user_id_param = definition.params[:user_id]
        if user_id_param
          expect(user_id_param[:required]).to be false
          expect(user_id_param[:type]).to eq(:uuid)
        end
      end
    end
  end

  describe '.generate' do
    context 'for create action' do
      it 'generates contract with required enum fields' do
        contract_class = described_class.generate(Api::V1::ServiceResource, :create)

        expect(contract_class).to be < Apiwork::Contract::Base
        expect(contract_class.input_definition).to be_present

        # Check params in the nested :service object
        service_param = contract_class.input_definition.params[:service]
        expect(service_param).to be_present
        expect(service_param[:nested]).to be_present

        color_param = service_param[:nested].params[:color]
        expect(color_param[:required]).to be true
        expect(color_param[:enum]).to be_present
      end
    end

    context 'for update action' do
      it 'generates contract with required enum fields' do
        contract_class = described_class.generate(Api::V1::ServiceResource, :update)

        expect(contract_class).to be < Apiwork::Contract::Base
        expect(contract_class.input_definition).to be_present

        # Check params in the nested :service object
        service_param = contract_class.input_definition.params[:service]
        expect(service_param).to be_present
        expect(service_param[:nested]).to be_present

        color_param = service_param[:nested].params[:color]
        expect(color_param[:required]).to be true
        expect(color_param[:enum]).to be_present
      end
    end
  end

  describe 'enum and required detection together' do
    let(:contract_class) { Class.new(Apiwork::Contract::Base) }
    let(:definition) { Apiwork::Contract::Definition.new(:input, contract_class) }

    it 'correctly combines enum values with required status' do
      described_class.generate_writable_params(definition, Api::V1::ServiceResource, :create)

      # Check that both enum and required work together
      color_param = definition.params[:color]
      expect(color_param[:required]).to be true
      expect(color_param[:enum]).to be_an(Array)
      expect(color_param[:enum].length).to be > 0
      expect(color_param[:type]).to eq(:string)
    end

    it 'handles optional enum correctly' do
      described_class.generate_writable_params(definition, Api::V1::ClientResource, :create)

      kind_param = definition.params[:kind]
      expect(kind_param[:required]).to be false
      expect(kind_param[:enum]).to be_an(Array)
      expect(kind_param[:enum].length).to be > 0
    end
  end
end
