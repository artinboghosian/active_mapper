require 'active_mapper/adapter/arel/order/attribute'

module ActiveMapper
  module Adapter
    class Arel
      class Order
        def initialize(table, block)
          @table = table
          @block = block
        end

        def call
          [@block.call(self)].flatten.map(&:call)
        end

        def method_missing(name, *args, &block)
          Attribute.new(@table[name].asc)
        end
      end
    end
  end
end