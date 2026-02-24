# frozen_string_literal: true

module LazyCow
  class StatusesController < ApplicationController
    def health
      expose(
        {
          status: 'ok',
          timestamp: Time.current,
          version: '1.0.0',
        },
      )
    end

    def stats
      expose(
        {
          posts_count: 5678,
          uptime_seconds: 86_400,
          users_count: 1234,
        },
      )
    end
  end
end
