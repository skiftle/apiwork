# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Object::Validator do
  describe '#validate' do
    it 'returns the result' do
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
      validator = described_class.new(shape)

      result = validator.validate({ title: 'First Post' })

      expect(result).to be_valid
      expect(result.params).to eq({ title: 'First Post' })
    end

    context 'when required field is missing' do
      it 'returns field_missing issue' do
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
        validator = described_class.new(shape)

        result = validator.validate({})

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:field_missing)
      end
    end

    context 'when field has invalid type' do
      it 'returns type_invalid issue' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                integer :amount
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ amount: 'First Post' })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:type_invalid)
      end
    end

    context 'when field is unknown' do
      it 'returns field_unknown issue' do
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
        validator = described_class.new(shape)

        result = validator.validate({ body: 'Rails tutorial', title: 'First Post' })

        expect(result.issues.map(&:code)).to include(:field_unknown)
      end
    end

    context 'when required object field is an empty hash' do
      it 'returns no issues' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                param :address, type: :object do
                  string? :street
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ address: {} })

        expect(result).to be_valid
      end
    end

    context 'when required array field is an empty array' do
      it 'returns no issues' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                array :tags do
                  string
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ tags: [] })

        expect(result).to be_valid
      end
    end

    context 'when non-nullable field is null' do
      it 'returns value_null issue' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                string? :title
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ title: nil })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:value_null)
      end
    end

    context 'when nullable field is null' do
      it 'returns no issues' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                string :title, nullable: true
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ title: nil })

        expect(result).to be_valid
      end
    end

    context 'when string exceeds max length' do
      it 'returns string_too_long issue' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                string :title, max: 5
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ title: 'First Post' })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:string_too_long)
      end
    end

    context 'when number is below minimum' do
      it 'returns number_too_small issue' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                integer :amount, min: 1
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ amount: 0 })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:number_too_small)
      end
    end

    context 'with nested object' do
      it 'returns type_invalid issue' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                param :address, type: :object do
                  string :street
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ address: { street: 42 } })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:type_invalid)
        expect(result.issues.first.path).to eq(%i[address street])
      end
    end

    context 'with array' do
      it 'returns type_invalid issue' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                array :tags do
                  string
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ tags: ['ruby', 42] })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:type_invalid)
      end
    end

    context 'with array of discriminated union' do
      it 'validates valid items' do
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
        validator = described_class.new(shape)

        result = validator.validate({ items: [{ kind: 'invoice', number: 'INV-001' }, { amount: 150.00, kind: 'payment' }] })

        expect(result).to be_valid
        expect(result.params[:items].length).to eq(2)
      end

      it 'returns value_invalid issue for wrong discriminator' do
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
        validator = described_class.new(shape)

        result = validator.validate({ items: [{ kind: 'unknown', number: 'INV-001' }] })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:value_invalid)
      end

      it 'returns type_invalid issue for invalid item field' do
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
        validator = described_class.new(shape)

        result = validator.validate({ items: [{ kind: 'invoice', number: 42 }] })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:type_invalid)
      end
    end

    context 'with array of simple union' do
      it 'validates valid items' do
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
        validator = described_class.new(shape)

        result = validator.validate({ values: ['ruby', 42] })

        expect(result).to be_valid
        expect(result.params[:values]).to eq(['ruby', 42])
      end

      it 'returns type_invalid issue for invalid item' do
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
        validator = described_class.new(shape)

        result = validator.validate({ values: ['ruby', 19.99] })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:type_invalid)
      end
    end

    context 'with record' do
      it 'validates record values' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                record :scores do
                  integer
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ scores: { math: 95, science: 87 } })

        expect(result).to be_valid
        expect(result.params[:scores]).to eq({ math: 95, science: 87 })
      end

      it 'returns type_invalid issue' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                record :scores do
                  integer
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        validator = described_class.new(shape)

        result = validator.validate({ scores: { math: 95, science: 'high' } })

        expect(result).to be_invalid
        expect(result.issues.first.code).to eq(:type_invalid)
      end
    end
  end
end
