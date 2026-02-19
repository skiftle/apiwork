# frozen_string_literal: true

module Api
  module V1
    class ItemsController < V1Controller
      before_action :set_item, only: %i[show update destroy]

      def index
        items = if params[:invoice_id]
                  Item.where(invoice_id: params[:invoice_id])
                else
                  Item.all
                end
        expose items
      end

      def show
        expose item
      end

      def create
        params_with_invoice = if params[:invoice_id]
                                contract.body[:item].merge(invoice_id: params[:invoice_id])
                              else
                                contract.body[:item]
                              end
        item = Item.create(params_with_invoice)
        expose item
      end

      def update
        item.update(contract.body[:item])
        expose item
      end

      def destroy
        item.destroy
        expose item
      end

      private

      attr_reader :item

      def set_item
        @item = if params[:invoice_id]
                  Item.where(invoice_id: params[:invoice_id]).find(params[:id])
                else
                  Item.find(params[:id])
                end
      end
    end
  end
end
