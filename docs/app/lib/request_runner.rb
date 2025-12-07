# frozen_string_literal: true

class RequestRunner
  include ActionDispatch::Integration::Runner

  def initialize(namespace, scenarios)
    @namespace = namespace
    @scenarios = scenarios
    @app = Rails.application
  end

  def run_all
    results = {}

    @scenarios.each do |action, scenario|
      clear_database
      results[action.to_sym] = run_scenario(scenario.deep_symbolize_keys)
    end

    results
  end

  private

  attr_reader :namespace

  def run_scenario(scenario)
    ids = run_setup(scenario[:setup])
    path = build_path(scenario[:path], ids)
    body = resolve_body_references(scenario[:body], ids)
    method = scenario[:method].downcase.to_sym

    execute_request(method, path, body)

    {
      request: build_request_data(scenario[:method], path, body),
      response: build_response_data
    }
  end

  def run_setup(setup)
    return {} unless setup

    ids = {}
    setup.each do |step|
      step = step.deep_symbolize_keys
      model_name = step[:create]
      model_class = "#{namespace.camelize}::#{model_name.to_s.camelize}".constantize
      attrs = resolve_fields(step[:fields], ids)
      record = model_class.create!(attrs)
      ids[model_name.to_sym] = record.id
    end
    ids
  end

  def resolve_fields(fields, ids)
    return {} unless fields

    fields.transform_values do |value|
      resolve_reference(value, ids)
    end
  end

  def resolve_body_references(body, ids)
    return nil unless body

    deep_resolve(body, ids)
  end

  def deep_resolve(obj, ids)
    case obj
    when Hash
      obj.transform_values { |v| deep_resolve(v, ids) }
    when Array
      obj.map { |v| deep_resolve(v, ids) }
    else
      resolve_reference(obj, ids)
    end
  end

  def resolve_reference(value, ids)
    # Symbol references like :customer_id from YAML
    if value.is_a?(Symbol)
      ref_name = value.to_s
      if ref_name.end_with?('_id')
        key = ref_name[0...-3].to_sym
      else
        key = ref_name.to_sym
      end
      return ids[key] if ids.key?(key)
    end

    # String references like ":customer_id"
    if value.is_a?(String) && value.start_with?(':')
      ref_name = value[1..]
      if ref_name.end_with?('_id')
        key = ref_name[0...-3].to_sym
      else
        key = ref_name.to_sym
      end
      return ids[key] if ids.key?(key)
    end

    value
  end

  def build_path(path_template, ids)
    path = path_template.dup

    # Replace specific :model_id references first
    ids.each do |key, id|
      path = path.gsub(":#{key}_id", id.to_s)
    end

    # Replace generic :id with the last created record's id
    if path.include?(':id') && ids.any?
      last_id = ids.values.last
      path = path.gsub(':id', last_id.to_s)
    end

    path
  end

  def execute_request(method, path, body)
    if body
      send(method, path, params: body.to_json, headers: json_headers)
    else
      send(method, path, headers: json_headers)
    end
  end

  def build_request_data(method, path, body)
    data = {
      method: method,
      path: path
    }
    data[:body] = body if body
    data
  end

  def build_response_data
    body = response.body.present? ? JSON.parse(response.body) : nil

    {
      status: response.status,
      body: body
    }.compact
  end

  def json_headers
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  def clear_database
    namespace_prefix = namespace.underscore
    connection = ActiveRecord::Base.connection

    connection.execute('PRAGMA foreign_keys = OFF')

    connection.tables.each do |table|
      next unless table.start_with?(namespace_prefix)

      connection.execute("DELETE FROM #{table}")
    end

    connection.execute('PRAGMA foreign_keys = ON')
  end
end
