# frozen_string_literal: true

module EagerLion
  class InvoiceContract < Apiwork::Contract::Base
    schema!

    action :archive do
      response do
        body param :invoice, type: :invoice do
        end
      end
    end
  end
end
