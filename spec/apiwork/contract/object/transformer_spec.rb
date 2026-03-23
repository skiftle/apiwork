# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Object::Transformer do
  describe '#transform' do
    it 'returns the transformed hash' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              string :title
            end
          end
        end
      end
      shape = contract_class.action_for(:create).request.body
      transformer = described_class.new(shape)

      result = transformer.transform({ title: 'First Post' })

      expect(result).to eq({ title: 'First Post' })
    end

    context 'when params is not a hash' do
      it 'returns the params' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                string :title
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        transformer = described_class.new(shape)

        result = transformer.transform('First Post')

        expect(result).to eq('First Post')
      end
    end

    context 'with as rename' do
      it 'returns the transformed hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                string :title, as: :name
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        transformer = described_class.new(shape)

        result = transformer.transform({ title: 'First Post' })

        expect(result).to eq({ name: 'First Post' })
      end
    end

    context 'with nested object' do
      it 'returns the transformed hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                param :address, type: :object do
                  string :street, as: :street_name
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        transformer = described_class.new(shape)

        result = transformer.transform({ address: { street: 'Main St' } })

        expect(result).to eq({ address: { street_name: 'Main St' } })
      end
    end

    context 'with array of objects' do
      it 'returns the transformed hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                array :items do
                  of :object do
                    string :title, as: :name
                  end
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        transformer = described_class.new(shape)

        result = transformer.transform({ items: [{ title: 'First Post' }, { title: 'Second Post' }] })

        expect(result).to eq({ items: [{ name: 'First Post' }, { name: 'Second Post' }] })
      end
    end

    context 'with record of objects' do
      it 'returns the transformed hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                record :settings do
                  object do
                    string :title, as: :name
                  end
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        transformer = described_class.new(shape)

        result = transformer.transform({ settings: { layout: { title: 'Wide' }, theme: { title: 'Dark' } } })

        expect(result).to eq({ settings: { layout: { name: 'Wide' }, theme: { name: 'Dark' } } })
      end
    end

    context 'with array of discriminated union' do
      it 'returns the transformed hash' do
        contract_class = create_test_contract do
          action :create do
            request do
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
        shape = contract_class.action_for(:create).request.body
        transformer = described_class.new(shape)

        result = transformer.transform({ items: [{ kind: 'invoice', number: 'INV-001' }, { amount: 150.00, kind: 'payment' }] })

        expect(result[:items]).to eq([{ kind: 'invoice', number: 'INV-001' }, { amount: 150.00, kind: 'payment' }])
      end
    end

    context 'with array of simple union' do
      it 'returns the transformed hash' do
        contract_class = create_test_contract do
          action :create do
            request do
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
        shape = contract_class.action_for(:create).request.body
        transformer = described_class.new(shape)

        result = transformer.transform({ values: ['ruby', 42] })

        expect(result[:values]).to eq(['ruby', 42])
      end
    end

    context 'when key is not present in hash' do
      it 'returns an empty hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                string :title
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        transformer = described_class.new(shape)

        result = transformer.transform({})

        expect(result).to eq({})
      end
    end
  end
end
