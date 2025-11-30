# frozen_string_literal: true

module FunnySnake
  class InvoiceContract < Apiwork::Contract::Base
    type :line do
      param :id, type: :uuid
      param :created_at, type: :datetime
      param :updated_at, type: :datetime
      param :description, type: :string
      param :quantity, type: :decimal
      param :price, type: :decimal
    end

    type :invoice do
      param :id, type: :uuid
      param :created_at, type: :datetime
      param :updated_at, type: :datetime
      param :number, type: :string
      param :issued_on, type: :date
      param :status, type: :string
      param :lines, type: :array, of: :line
    end

    type :payload do
      param :number, type: :string
      param :issued_on, type: :date
      param :notes, type: :string
      param :lines_attributes, type: :array do
        param :_destroy, type: :boolean
        param :id, type: :uuid
        param :description, type: :string
        param :quantity, type: :integer
        param :price, type: :decimal
      end
    end

    action :index do
      request do
        query do
          param :filter, type: :object do
            param :status, type: :string
          end
          param :sort, type: :object do
            param :issued_on, type: :string, enum: %w[asc desc]
          end
        end
      end

      response do
        body do
          param :invoices, type: :array, of: :invoice
        end
      end
    end

    action :show do
      response do
        body do
          param :invoice, type: :invoice
        end
      end
    end

    action :create do
      request do
        body do
          param :invoice, type: :payload, required: true
        end
      end

      response do
        body do
          param :invoice, type: :invoice
        end
      end
    end

    action :update do
      request do
        body do
          param :invoice, type: :payload, required: true
        end
      end

      response do
        body do
          param :invoice, type: :invoice
        end
      end
    end

    action :destroy

    action :archive do
      response do
        body do
          param :invoice, type: :invoice
        end
      end
    end
  end
end
