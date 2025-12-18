# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create :set_id

  class << self
    def generate_uuid
      @seq = (@seq || 0) + 1
      Digest::UUID.uuid_v5(Digest::UUID::DNS_NAMESPACE, "#{table_name}:#{@seq}")
    end

    def inherited(subclass)
      super
      return if subclass.name&.exclude?('::')
      return unless subclass.superclass.abstract_class?

      namespace = subclass.name.deconstantize.underscore.tr('/', '_')
      model_name = subclass.name.demodulize.underscore.pluralize
      subclass.table_name = "#{namespace}_#{model_name}"
    end
  end

  private

  def set_id
    self.id ||= self.class.generate_uuid
  end
end
