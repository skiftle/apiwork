# frozen_string_literal: true

module FunnySnake
  class InvoiceContract < Apiwork::Contract::Base
    enum :status, values: %w[draft sent paid]

    object :invoice do
      uuid :id
      datetime :created_at
      datetime :updated_at
      string :number
      date :issued_on
      string :status, enum: :status
      string :notes
    end

    object :create_payload do
      string :number
      date :issued_on
      string :status, enum: :status
      string :notes
    end

    object :update_payload do
      string? :number
      date? :issued_on
      string? :status, enum: :status
      string? :notes
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
          reference :invoice, to: :create_payload
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
          reference :invoice, to: :update_payload
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
