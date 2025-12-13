# frozen_string_literal: true

module Api
  module V1
    class ServicesController < V1Controller
      before_action :set_service, only: %i[show update destroy]

      def index
        render_with_contract Service.all
      end

      def show
        render_with_contract service
      end

      def create
        service = Service.create(contract.body[:service])
        render_with_contract service
      end

      def update
        service.update(contract.body[:service])
        render_with_contract service
      end

      def destroy
        service.destroy
        render_with_contract service
      end

      private

      attr_reader :service

      def set_service
        @service = Service.find(params[:id])
      end
    end
  end
end
