# frozen_string_literal: true

module EagerLion
  class InvoiceContract < Apiwork::Contract::Base
    schema!

    action :archive do
      response do
        body do
          param :invoice, type: :invoice
        end
      end
    end
  end
end
