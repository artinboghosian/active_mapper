module ActiveMapper
  module Adapter
    class ActiveRecord
      class Query
        def initialize(table, &block)
          @table = table
          @block = block
        end

        def to_sql
          @block ? @block.call(self).to_sql : {}
        end

        def method_missing(name, *args, &block)
          QueryAttribute.new(@table[name])
        end
      end
    end
  end
end