module ActiveMapper
  module Adapter
    class ActiveRecord
      class QueryExpression
        def initialize(attribute, comparator, value)
          @attribute = attribute
          @comparator = comparator
          @value = value
        end

        def to_sql
          @attribute.send(@comparator, @value)
        end

        def &(expression)
          CompositeQueryExpression.new(self, :and, expression)
        end

        def |(expression)
          CompositeQueryExpression.new(self, :or, expression)
        end
      end

      class CompositeQueryExpression < QueryExpression
        def initialize(left, comparator, right)
          @left = left
          @comparator = comparator
          @right = right
        end

        def to_sql
          @left.to_sql.send(@comparator, @right.to_sql)
        end
      end
    end
  end
end