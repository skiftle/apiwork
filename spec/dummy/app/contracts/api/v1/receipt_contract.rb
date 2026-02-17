# frozen_string_literal: true

module Api
  module V1
    class ReceiptContract < Apiwork::Contract::Base
      representation ReceiptRepresentation

      action :create do
        request replace: true do
          body do
            object :receipt do
              string :number
            end
          end
        end
      end

      action :update do
        request replace: true do
          body do
            object :receipt do
              string :number
            end
          end
        end
      end
    end
  end
end
