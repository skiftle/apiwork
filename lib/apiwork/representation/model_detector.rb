# frozen_string_literal: true

module Apiwork
  module Representation
    class ModelDetector
      def initialize(representation_class)
        @representation_class = representation_class
      end

      def detect
        return nil if @representation_class.abstract?

        full_name = @representation_class.name
        return nil unless full_name

        representation_name = full_name.demodulize
        model_name = representation_name.delete_suffix('Representation')
        return nil if model_name.blank?

        resolve_model_class(full_name, model_name)
      end

      def sti_base?(model_class)
        return false if model_class.abstract_class?

        column = model_class.inheritance_column
        return false unless column

        begin
          return false unless model_class.column_names.include?(column.to_s)
        rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
          return false
        end

        model_class == model_class.base_class
      end

      def sti_subclass?(model_class)
        return false if model_class.abstract_class?

        model_class != model_class.base_class
      end

      def superclass_is_sti_base?(model_class)
        parent_model = @representation_class.superclass.model_class
        return false unless parent_model

        parent_model == model_class.base_class
      end

      private

      def resolve_model_class(full_name, model_name)
        namespace = full_name.deconstantize
        model_class = if namespace.present?
                        "#{namespace}::#{model_name}".safe_constantize || model_name.safe_constantize
                      else
                        model_name.safe_constantize
                      end

        if model_class.is_a?(Class) && model_class < ActiveRecord::Base
          model_class
        else
          raise ConfigurationError.new(
            code: :model_not_found,
            detail: "Could not find model '#{model_name}' for #{full_name}. " \
                    "Either create the model, declare it explicitly with 'model YourModel', " \
                    "or mark this representation as abstract with 'abstract!'",
            path: [],
          )
        end
      end
    end
  end
end
