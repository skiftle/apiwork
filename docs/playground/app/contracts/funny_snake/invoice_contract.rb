# frozen_string_literal: true

module FunnySnake
  class InvoiceContract < Apiwork::Contract::Base
    type :invoice do
      param :id, type: :uuid
      param :created_at, type: :datetime
      param :updated_at, type: :datetime
      param :number, type: :string
      param :issued_on, type: :date
      param :status, type: :string
      param :notes, type: :string
    end

    type :payload do
      param :number, type: :string
      param :issued_on, type: :date
      param :status, type: :string
      param :notes, type: :string
    end

    action :index do
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
          param :invoice, type: :payload
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
          param :invoice, type: :payload
        end
      end

      response do
        body do
          param :invoice, type: :invoice
        end
      end
    end

    action :destroy do
      response { no_content! }
    end
  end
end
