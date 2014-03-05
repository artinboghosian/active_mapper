require 'active_mapper/adapter/active_record/order/attribute'

module ActiveMapper
  module Adapter
    class ActiveRecord
      class Order
        def initialize(&block)
          @block = block
        end

        def to_sql
          attributes.inject({}) do |memo, attribute|
            memo = memo.merge(attribute.to_sql)
            memo
          end
        end

        def method_missing(name, *args, &block)
          Attribute.new(name)
        end

        private

        def attributes
          @block ? @block.call(self) : []
        end
      end
    end
  end
end