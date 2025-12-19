# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  # @api private
  class Store
    def initialize
      @items = Concurrent::Map.new
    end

    def [](key)
      @items[key]
    end

    def []=(key, value)
      @items[key] = value
    end

    def fetch(key, &block)
      @items.fetch(key, &block)
    end

    def key?(key)
      @items.key?(key)
    end

    def delete(key)
      @items.delete(key)
    end

    def keys
      @items.keys
    end

    def values
      @items.values
    end

    def each_pair(&block)
      @items.each_pair(&block)
    end

    def clear!
      @items = Concurrent::Map.new
    end
  end
end
