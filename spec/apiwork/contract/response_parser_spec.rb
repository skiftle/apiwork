# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::ResponseParser do
  describe '#parse' do
    it 'returns the result' do
      contract_class = create_test_contract do
        action :show do
          response do
            body do
              string :title
            end
          end
        end
      end
      parser = described_class.new(contract_class, :show)
      response = Apiwork::Response.new(body: { title: 'First Post' })

      result = parser.parse(response)

      expect(result.issues).to be_empty
      expect(result.response.body).to eq({ title: 'First Post' })
    end

    context 'when action does not exist' do
      it 'returns the original response' do
        contract_class = create_test_contract
        parser = described_class.new(contract_class, :nonexistent)
        response = Apiwork::Response.new(body: { title: 'First Post' })

        result = parser.parse(response)

        expect(result.response).to eq(response)
      end
    end

    context 'when response has no body shape' do
      it 'returns the original response' do
        contract_class = create_test_contract do
          action :show do
            request do
              query do
                string :title
              end
            end
          end
        end
        parser = described_class.new(contract_class, :show)
        response = Apiwork::Response.new(body: {})

        result = parser.parse(response)

        expect(result.response).to eq(response)
      end
    end

    context 'when shape has no params' do
      it 'returns the original response' do
        contract_class = create_test_contract do
          action :show do
            response do
              body {}
            end
          end
        end
        parser = described_class.new(contract_class, :show)
        response = Apiwork::Response.new(body: {})

        result = parser.parse(response)

        expect(result.response).to eq(response)
      end
    end
  end
end
