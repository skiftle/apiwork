# frozen_string_literal: true

module Api
  module V1
    class ClientsController < V1Controller
      before_action :set_client, only: %i[show update destroy]

      def index
        render_with_contract Client.all
      end

      def show
        render_with_contract client
      end

      def create
        client = Client.create(contract.body[:client])
        render_with_contract client
      end

      def update
        client.update(contract.body[:client])
        render_with_contract client
      end

      def destroy
        client.destroy
        render_with_contract client
      end

      private

      attr_reader :client

      def set_client
        @client = Client.find(params[:id])
      end
    end
  end
end
