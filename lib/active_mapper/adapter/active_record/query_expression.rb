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

        def !
          NotQueryExpression.new(self)
        end

        def &(expression)
          AndQueryExpression.new(self, expression)
        end

        def |(expression)
          OrQueryExpression.new(self, expression)
        end
      end

      class NotQueryExpression < QueryExpression
        def initialize(expression)
          @expression = expression
        end

        def to_sql
          @expression.to_sql.not
        end
      end

      class AndQueryExpression < QueryExpression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def to_sql
          @left.to_sql.and(@right.to_sql)
        end
      end

      class OrQueryExpression < QueryExpression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def to_sql
          @left.to_sql.or(@right.to_sql)
        end
      end
    end
  end
end