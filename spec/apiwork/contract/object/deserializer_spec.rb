# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Object::Deserializer do
  describe '#deserialize' do
    it 'returns the deserialized hash' do
      contract_class = create_test_contract do
        action :show do
          response do
            body do
              string :title
            end
          end
        end
      end
      shape = contract_class.action_for(:show).response.body
      deserializer = described_class.new(shape)

      result = deserializer.deserialize({ title: 'First Post' })

      expect(result).to eq({ title: 'First Post' })
    end

    context 'with nested object' do
      it 'returns the deserialized hash' do
        contract_class = create_test_contract do
          action :show do
            response do
              body do
                param :address, type: :object do
                  string :street
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:show).response.body
        deserializer = described_class.new(shape)

        result = deserializer.deserialize({ address: { street: 'Main St' } })

        expect(result).to eq({ address: { street: 'Main St' } })
      end
    end

    context 'with array' do
      it 'returns the deserialized hash' do
        contract_class = create_test_contract do
          action :show do
            response do
              body do
                array :tags do
                  string
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:show).response.body
        deserializer = described_class.new(shape)

        result = deserializer.deserialize({ tags: %w[ruby rails] })

        expect(result).to eq({ tags: %w[ruby rails] })
      end
    end

    context 'with array of discriminated union' do
      it 'returns the deserialized hash' do
        contract_class = create_test_contract do
          action :show do
            response do
              body do
                array :items do
                  of :union, discriminator: :kind do
                    variant tag: 'invoice' do
                      object do
                        string :number
                      end
                    end
                    variant tag: 'payment' do
                      object do
                        decimal :amount
                      end
                    end
                  end
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:show).response.body
        deserializer = described_class.new(shape)

        result = deserializer.deserialize({ items: [{ kind: 'invoice', number: 'INV-001' }, { amount: 150.00, kind: 'payment' }] })

        expect(result[:items].length).to eq(2)
        expect(result[:items][0][:kind]).to eq('invoice')
        expect(result[:items][0][:number]).to eq('INV-001')
        expect(result[:items][1][:kind]).to eq('payment')
        expect(result[:items][1][:amount]).to eq(150.00)
      end
    end

    context 'with array of simple union' do
      it 'returns the deserialized hash' do
        contract_class = create_test_contract do
          action :show do
            response do
              body do
                array :values do
                  of :union do
                    variant do
                      string
                    end
                    variant do
                      integer
                    end
                  end
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:show).response.body
        deserializer = described_class.new(shape)

        result = deserializer.deserialize({ values: ['ruby', 42] })

        expect(result[:values]).to eq(['ruby', 42])
      end
    end

    context 'when key is not present in hash' do
      it 'returns an empty hash' do
        contract_class = create_test_contract do
          action :show do
            response do
              body do
                string :title
              end
            end
          end
        end
        shape = contract_class.action_for(:show).response.body
        deserializer = described_class.new(shape)

        result = deserializer.deserialize({})

        expect(result).to eq({})
      end
    end
  end
end
