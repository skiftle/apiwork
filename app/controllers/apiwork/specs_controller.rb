# frozen_string_literal: true

module Apiwork
  class SpecsController < ActionController::API
    def show
      api_class = API.find(params[:api_path])
      spec_name = params[:spec_name].to_sym
      spec_class = Spec.find(spec_name)

      raw = { key_format: api_class.key_format }
        .merge(api_class.spec_config(spec_name))
        .merge(params.to_unsafe_h.symbolize_keys)

      options = spec_class.extract_options(raw)

      format = options[:format]
      result = Spec.generate(spec_name, api_class.path, **options)
      spec = spec_class.new(api_class.path)

      render content_type: spec.content_type_for(format:), plain: result
    end
  end
end
