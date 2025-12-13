# frozen_string_literal: true

module Api
  module V1
    class ServicesController < V1Controller
      before_action :set_service, only: %i[show update destroy]

      def index
        respond Service.all
      end

      def show
        respond service
      end

      def create
        service = Service.create(contract.body[:service])
        respond service
      end

      def update
        service.update(contract.body[:service])
        respond service
      end

      def destroy
        service.destroy
        respond service
      end

      private

      attr_reader :service

      def set_service
        @service = Service.find(params[:id])
      end
    end
  end
end
