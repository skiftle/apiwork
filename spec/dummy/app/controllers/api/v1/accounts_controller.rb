# frozen_string_literal: true

module Api
  module V1
    class AccountsController < V1Controller
      def show
        account = Account.first || Account.create!(name: 'Test Account', status: :active)

        # Deliberately set an invalid enum value to test output validation
        # Override the getter to return an invalid value
        account.define_singleton_method(:first_day_of_week) { 'hahahahahaha' }

        respond_with account
      end
    end
  end
end
