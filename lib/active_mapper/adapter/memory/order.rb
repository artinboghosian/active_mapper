require 'active_mapper/adapter/memory/order/attribute'

module ActiveMapper
  module Adapter
    class Memory
      class Order
        def initialize(&block)
          @block = block
        end

        def to_proc
          proc do |x,y|
            [attributes].flatten.sum do |attribute|
              attribute.to_proc.call(x,y)
            end
          end
        end

        def method_missing(name, *args, &block)
          Attribute.new(name)
        end

        private

        def attributes
          @block ? @block.call(self) : [id]
        end
      end
    end
  end
end