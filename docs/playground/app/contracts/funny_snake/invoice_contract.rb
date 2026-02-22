# frozen_string_literal: true

module FunnySnake
  class InvoiceContract < Apiwork::Contract::Base
    object :invoice do
      uuid :id
      datetime :created_at
      datetime :updated_at
      string :number
      date :issued_on
      string :status, enum: %w[draft sent paid]
      string :notes
    end

    object :payload do
      string :number
      date :issued_on
      string :status, enum: %w[draft sent paid]
      string :notes
    end

    action :index do
      response do
        body do
          array :invoices do
            reference :invoice
          end
        end
      end
    end

    action :show do
      response do
        body do
          reference :invoice
        end
      end
    end

    action :create do
      request do
        body do
          reference :invoice, to: :payload
        end
      end

      response do
        body do
          reference :invoice
        end
      end
    end

    action :update do
      request do
        body do
          reference :invoice, to: :payload
        end
      end

      response do
        body do
          reference :invoice
        end
      end
    end

    action :destroy do
      response { no_content! }
    end
  end
end
