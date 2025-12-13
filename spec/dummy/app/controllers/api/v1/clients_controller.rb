# frozen_string_literal: true

module Api
  module V1
    class ClientsController < V1Controller
      before_action :set_client, only: %i[show update destroy]

      def index
        respond Client.all
      end

      def show
        respond client
      end

      def create
        client = Client.create(contract.body[:client])
        respond client
      end

      def update
        client.update(contract.body[:client])
        respond client
      end

      def destroy
        client.destroy
        respond client
      end

      private

      attr_reader :client

      def set_client
        @client = Client.find(params[:id])
      end
    end
  end
end
