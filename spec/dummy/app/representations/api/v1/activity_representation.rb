# frozen_string_literal: true

module Api
  module V1
    class ActivityRepresentation < Apiwork::Representation::Base
      adapter do
        pagination do
          strategy :cursor
        end
      end

      with_options filterable: true, sortable: true do
        attribute :action
        attribute :created_at
        attribute :id
        attribute :read
        attribute :target_id
        attribute :target_type
        attribute :updated_at
      end
    end
  end
end
