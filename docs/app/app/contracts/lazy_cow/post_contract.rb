# frozen_string_literal: true

module LazyCow
  class PostContract < Apiwork::Contract::Base
    enum :priority, values: %i[low medium high critical]
  end
end
