# frozen_string_literal: true

module Api
  module V1
    class CamelizedAccountsController < V1Controller
      def show
        account = Account.find_by(id: params[:id])

        # If account doesn't exist or has ID = 1, deliberately set an invalid enum value
        if account.nil? || params[:id] == '1'
          account ||= Account.create!(name: 'Test Account', status: :active)
          account.define_singleton_method(:first_day_of_week) { 'hahahahahaha' }
        end

        respond_with account
      end
    end
  end
end
