# frozen_string_literal: true

module LazyCow
  class StatusContract < Apiwork::Contract::Base
    action :health do
      response do
        body do
          param :status, type: :string
          param :timestamp, type: :datetime
          param :version, type: :string
        end
      end
    end

    action :stats do
      response do
        body do
          param :users_count, type: :integer
          param :posts_count, type: :integer
          param :uptime_seconds, type: :integer
        end
      end
    end
  end
end
