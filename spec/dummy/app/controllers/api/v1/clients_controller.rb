# frozen_string_literal: true

module Api
  module V1
    class ClientsController < V1Controller
      before_action :set_client, only: %i[show update destroy]

      def index
        respond_with Client.all
      end

      def show
        respond_with client
      end

      def create
        client = Client.create(action_input[:client])
        respond_with client
      end

      def update
        client.update(action_input[:client])
        respond_with client
      end

      def destroy
        client.destroy
        respond_with client
      end

      private

      attr_reader :client

      def set_client
        @client = Client.find(params[:id])
      end
    end
  end
end
