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
        params = sti_params(contract.body[:client])
        client = Client.create(params)
        expose client
      end

      def update
        params = sti_params(contract.body[:client])
        client.update(params)
        expose client
      end

      def sti_params(params)
        # Transform STI discriminator: kind -> type
        # The contract transforms the value (person -> PersonClient)
        # but key rename isn't applied for union variants yet
        if params[:kind]
          params.merge(type: params.delete(:kind))
        else
          params
        end
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
