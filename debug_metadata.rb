# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative 'spec/dummy/config/environment'

# Force API loading
require_relative 'spec/dummy/config/apis/v1'

api = Apiwork::API.find('/api/v1')
puts "API: #{api.inspect}"
puts "\nResources:"
api.metadata.resources.each do |name, data|
  puts "  #{name}: schema=#{data[:schema_class].inspect}"
  if data[:members]&.any?
    puts '    Members:'
    data[:members].each do |action_name, action_data|
      puts "      #{action_name}: #{action_data.inspect}"
    end
  end
  next unless data[:collections]&.any?

  puts '    Collections:'
  data[:collections].each do |action_name, action_data|
    puts "      #{action_name}: #{action_data.inspect}"
  end
end
