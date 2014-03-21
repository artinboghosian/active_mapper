require 'active_mapper/adapter/arel/query/attribute'
require 'active_mapper/adapter/arel/query/expression'

module ActiveMapper
  module Adapter
    class Arel
      class Query
        def initialize(table, block)
          @table = table
          @block = block
        end

        def call
          @block.call(self).call
        end

        def method_missing(name, *args, &block)
          Attribute.new(@table[name])
        end
      end
    end
  end
end