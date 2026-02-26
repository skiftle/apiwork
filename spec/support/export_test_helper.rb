# frozen_string_literal: true

module ExportTestHelper
  def build_param(type:, **options)
    Apiwork::Introspection::Param.build({ type: }.merge(options))
  end

  def build_type(shape: {}, extends: [], **options)
    dump = { extends:, shape:, type: :object, variants: [] }.merge(options)
    Apiwork::Introspection::Type.new(dump)
  end

  def build_union_type(variants:, discriminator: nil, **options)
    dump = { discriminator:, variants:, extends: [], shape: {}, type: :union }.merge(options)
    Apiwork::Introspection::Type.new(dump)
  end

  def build_enum(values:, **options)
    Apiwork::Introspection::Enum.new({ values: }.merge(options))
  end

  def stub_response(no_content: false)
    Struct.new(:no_content) { alias_method :no_content?, :no_content }.new(no_content)
  end

  def stub_error_code(status:)
    Struct.new(:status).new(status)
  end

  def stub_export(enums: {}, error_codes: {}, resources: {}, types: {})
    api_stub = Struct.new(:types, :enums, :resources, :error_codes).new(types, enums, resources, error_codes)
    export = Struct.new(:api).new(api_stub)
    export.define_singleton_method(:transform_key, &:to_s)
    export
  end
end

RSpec.configure do |config|
  config.include ExportTestHelper
end
