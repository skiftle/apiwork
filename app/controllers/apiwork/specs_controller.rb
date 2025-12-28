# frozen_string_literal: true

module Apiwork
  class SpecsController < ActionController::API
    def show
      api_class = Apiwork::API.find(params[:api_path])
      spec_name = params[:spec_name].to_sym
      spec_class = Apiwork::Spec.find(spec_name)

      options = { key_format: api_class.key_format }
                .merge(api_class.spec_config(spec_name))
                .merge(spec_class.extract_options(params))
                .compact

      result = Apiwork::Spec.generate(spec_name, api_class.path, **options)

      if spec_class.content_type.start_with?('application/json')
        render json: result
      else
        render plain: result, content_type: spec_class.content_type
      end
    end
  end
end
