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
          QueryExpression.new(to_sql, :and, expression.to_sql)
        end

        def |(expression)
          QueryExpression.new(to_sql, :or, expression.to_sql)
        end
      end
    end
  end
end