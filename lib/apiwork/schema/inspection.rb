# frozen_string_literal: true

module Apiwork
  module Schema
    # Inspection - ActiveRecord-specific introspection methods
    # This module is extended into Schema::Base to provide class-level introspection
    #
    # Currently minimal - most inspection logic is handled by individual
    # AttributeDefinition and AssociationDefinition classes.
    module Inspection
      # Reserved for future class-level model introspection methods
    end
  end
end