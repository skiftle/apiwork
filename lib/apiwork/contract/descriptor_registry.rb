# frozen_string_literal: true

require_relative 'descriptor_registry/registry'

module Apiwork
  module Contract
    # Expose Registry as DescriptorRegistry at this namespace level
    # This allows code to use: Contract::DescriptorRegistry instead of Contract::DescriptorRegistry::Registry
    DescriptorRegistry = DescriptorRegistry::Registry
  end
end
