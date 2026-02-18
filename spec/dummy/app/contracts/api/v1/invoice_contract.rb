# frozen_string_literal: true

module Api
  module V1
    class InvoiceContract < Apiwork::Contract::Base
      representation InvoiceRepresentation

      action :index do
        summary 'List all invoices'
        description 'Returns a paginated list of all invoices'
        tags :invoices, :public
      end

      action :show do
        summary 'Get an invoice'
        description 'Returns a single invoice by ID'
        raises :not_found, :forbidden
      end

      action :create do
        raises :unprocessable_entity

        request do
          body do
            object :invoice do
              string :number
              string :notes, optional: true
              boolean :sent, default: false
              integer :customer_id
            end
          end
        end
      end

      action :update do
        raises :not_found, :unprocessable_entity

        request do
          body do
            object :invoice do
              string :number, optional: true
              string :notes, optional: true
              boolean :sent, optional: true
            end
          end
        end
      end

      action :send_invoice do
        request do
          body do
            string :recipient_email, format: :email
            string :callback_url, format: :url, optional: true
            string :message, max: 500, min: 1, optional: true
            boolean :notify_customer, default: true, optional: true
          end
        end

        response do
          body do
            datetime :sent_at, optional: true
          end
        end
      end

      action :void do
        request do
          body do
            string :reason, optional: true
          end
        end

        response do
          body do
            datetime :voided_at, optional: true
            string :void_reason, optional: true
          end
        end
      end

      action :search do
        request do
          query do
            string :q, default: '', optional: true
          end
        end

        response do
          body do
            string :search_query, optional: true
            integer :result_count, optional: true
          end
        end
      end

      action :bulk_create do
        request do
          body do
            array :invoices, default: [], optional: true do
              object do
                string :number
                integer :customer_id
                boolean :sent, default: false, optional: true
              end
            end
          end
        end
      end

      action :destroy do
        summary 'Delete an invoice'
        deprecated!
        operation_id 'deleteInvoice'

        response replace: true do
          body do
            uuid :deleted_id
          end
        end
      end
    end
  end
end
