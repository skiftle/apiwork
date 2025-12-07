# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create :set_uuid

  def self.inherited(subclass)
    super
    return unless subclass.name&.include?('::')

    namespace = subclass.name.deconstantize.underscore.tr('/', '_')
    model_name = subclass.name.demodulize.underscore.pluralize
    subclass.table_name = "#{namespace}_#{model_name}"
  end

  private

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
