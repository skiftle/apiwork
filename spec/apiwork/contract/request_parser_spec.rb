# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::RequestParser do
  describe '#parse' do
    it 'returns the result' do
      contract_class = create_test_contract do
        action :create do
          request do
            query do
              integer :page
            end
            body do
              string :title
            end
          end
        end
      end
      parser = described_class.new(contract_class, :create)
      request = Apiwork::Request.new(body: { title: 'First Post' }, query: { page: 1 })

      result = parser.parse(request)

      expect(result.issues).to be_empty
      expect(result.request.query).to eq({ page: 1 })
      expect(result.request.body).to eq({ title: 'First Post' })
    end

    context 'when action does not exist' do
      it 'returns empty params' do
        contract_class = create_test_contract
        parser = described_class.new(contract_class, :nonexistent)
        request = Apiwork::Request.new(body: {}, query: {})

        result = parser.parse(request)

        expect(result.issues).to be_empty
        expect(result.request.query).to eq({})
        expect(result.request.body).to eq({})
      end
    end

    context 'when action does not exist but data is present' do
      it 'returns the original data' do
        contract_class = create_test_contract
        parser = described_class.new(contract_class, :nonexistent)
        request = Apiwork::Request.new(body: { title: 'First Post' }, query: { page: 1 })

        result = parser.parse(request)

        expect(result.issues).to be_empty
        expect(result.request.query).to eq({ page: 1 })
        expect(result.request.body).to eq({ title: 'First Post' })
      end
    end

    context 'when data is invalid' do
      it 'returns issues' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                string :title
              end
            end
          end
        end
        parser = described_class.new(contract_class, :create)
        request = Apiwork::Request.new(body: {}, query: {})

        result = parser.parse(request)

        expect(result.issues).not_to be_empty
      end
    end

    context 'with coerce' do
      it 'returns the coerced result' do
        contract_class = create_test_contract do
          action :create do
            request do
              query do
                integer :page
              end
            end
          end
        end
        parser = described_class.new(contract_class, :create)
        request = Apiwork::Request.new(body: {}, query: { page: '1' })

        result = parser.parse(request, coerce: true)

        expect(result.issues).to be_empty
        expect(result.request.query).to eq({ page: 1 })
      end
    end
  end
end
