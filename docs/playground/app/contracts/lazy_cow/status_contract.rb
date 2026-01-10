# frozen_string_literal: true

module LazyCow
  class StatusContract < Apiwork::Contract::Base
    action :health do
      response do
        body do
          string :status
          datetime :timestamp
          string :version
        end
      end
    end

    action :stats do
      response do
        body do
          integer :users_count
          integer :posts_count
          integer :uptime_seconds
        end
      end
    end
  end
end
