# frozen_string_literal: true

module Api
  module V1
    class ActivitySchema < Apiwork::Schema::Base
      adapter do
        pagination do
          strategy :cursor
        end
      end

      with_options filterable: true, sortable: true do
        attribute :id
        attribute :action
        attribute :target_type
        attribute :target_id
        attribute :read
        attribute :created_at
        attribute :updated_at
      end
    end
  end
end
