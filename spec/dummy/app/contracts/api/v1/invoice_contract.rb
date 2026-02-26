# frozen_string_literal: true

module Api
  module V1
    class InvoiceContract < ApplicationContract
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

        response do
          description 'The invoice'
        end
      end

      action :create do
        raises :unprocessable_entity

        request do
          body do
            object :invoice do
              string :number
              boolean :sent, default: false
              integer :customer_id
              string? :notes
            end
          end
        end
      end

      action :update do
        raises :not_found, :unprocessable_entity

        request do
          body do
            object :invoice do
              string? :number
              string? :notes
              boolean? :sent
            end
          end
        end
      end

      action :send_invoice do
        request do
          body do
            string :recipient_email, format: :email
            string? :callback_url, format: :url
            string? :message, max: 500, min: 1
            boolean? :notify_customer, default: true
          end
        end

        response do
          body do
            datetime? :sent_at
          end
        end
      end

      action :void do
        request do
          body do
            string? :reason
          end
        end

        response do
          body do
            datetime? :voided_at
            string? :void_reason
          end
        end
      end

      action :search do
        request do
          query do
            string? :q, default: ''
          end
        end

        response do
          body do
            string? :search_query
            integer? :result_count
          end
        end
      end

      action :bulk_create do
        request do
          body do
            array? :invoices, default: [] do
              object do
                string :number
                integer :customer_id
                boolean? :sent, default: false
              end
            end
          end
        end
      end

      action :destroy do
        summary 'Delete an invoice'
        operation_id 'deleteInvoice'
        deprecated!

        response replace: true do
          body do
            uuid :deleted_id
          end
        end
      end
    end
  end
end
