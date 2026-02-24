# frozen_string_literal: true

module BrightParrot
  class NotificationsController < ApplicationController
    def index
      expose(
        [
          {
            address: 'alice@example.com',
            channel: 'email',
            digest: true,
          },
          {
            channel: 'sms',
            phone_number: '+1234567890',
          },
          {
            channel: 'push',
            device_token: 'abc123def456',
            silent: false,
          },
        ],
      )
    end

    def create
      expose(contract.body[:preference])
    end
  end
end
