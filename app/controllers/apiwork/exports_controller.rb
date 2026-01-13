# frozen_string_literal: true

module Apiwork
  class ExportsController < ActionController::API
    def show
      api_class = API.find!(params[:api_path])
      export_name = params[:export_name].to_sym
      export_class = Export.find!(export_name)

      options = { key_format: api_class.key_format }
        .merge(api_class.export_config(export_name))
        .merge(params.to_unsafe_h.symbolize_keys)

      options = export_class.extract_options(options)

      format = options[:format]
      result = Export.generate(export_name, api_class.path, **options)
      export = export_class.new(api_class.path)

      render content_type: export.content_type_for(format:), plain: result
    end
  end
end
