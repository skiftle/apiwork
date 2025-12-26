# frozen_string_literal: true

module Api
  module V1
    class ClientsController < V1Controller
      before_action :set_client, only: %i[show update destroy]

      def index
        expose Client.all
      end

      def show
        expose client
      end

      def create
        client = Client.create(contract.body[:client])
        expose client
      end

      def update
        client.update(contract.body[:client])
        expose client
      end

      def destroy
        client.destroy
        expose client
      end

      private

      attr_reader :client

      def set_client
        @client = Client.find(params[:id])
      end
    end
  end
end
