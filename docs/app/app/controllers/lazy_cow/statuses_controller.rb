# frozen_string_literal: true

module LazyCow
  class StatusesController < ApplicationController
    def health
      respond_with({
                     status: 'ok',
                     timestamp: Time.current,
                     version: '1.0.0'
                   })
    end

    def stats
      respond_with({
                     users_count: 1234,
                     posts_count: 5678,
                     uptime_seconds: 86_400
                   })
    end
  end
end
