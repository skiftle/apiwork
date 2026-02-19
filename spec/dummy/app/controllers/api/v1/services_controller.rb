# frozen_string_literal: true

module Api
  module V1
    class ServicesController < V1Controller
      skip_contract_validation! only: [:deactivate]

      before_action :set_service, only: %i[show update destroy archive deactivate expire restrict]

      def index
        expose Service.all
      end

      def show
        expose service
      end

      def create
        service = Service.create(contract.body[:service])
        expose service
      end

      def update
        service.update(contract.body[:service])
        expose service
      end

      def destroy
        service.destroy
        expose service
      end

      def archive
        expose_error :forbidden, detail: 'Service is archived', meta: { reason: 'archived' }, path: [:service]
      end

      def deactivate
        expose service
      end

      def expire
        expose_error :not_found
      end

      def restrict
        expose_error :forbidden
      end

      private

      attr_reader :service

      def set_service
        @service = Service.find(params[:id])
      end
    end
  end
end
