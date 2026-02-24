# frozen_string_literal: true

module BrightParrot
  class NotificationContract < Apiwork::Contract::Base
    union :preference, discriminator: :channel do
      variant tag: 'email' do
        object do
          string :address
          boolean :digest
        end
      end

      variant tag: 'sms' do
        object do
          string :phone_number
        end
      end

      variant tag: 'push' do
        object do
          string :device_token
          boolean :silent
        end
      end
    end

    action :create do
      request do
        body do
          reference :preference
        end
      end

      response do
        body do
          reference :preference
        end
      end
    end

    action :index do
      response do
        body do
          reference :preference
        end
      end
    end
  end
end
