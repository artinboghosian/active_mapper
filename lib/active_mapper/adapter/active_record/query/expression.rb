module ActiveMapper
  module Adapter
    class ActiveRecord
      class Query
        class Expression
          def initialize(attribute, comparator, value)
            @attribute = attribute
            @comparator = comparator
            @value = value
          end

          def to_sql
            @attribute.send(@comparator, @value)
          end

          def !
            NotExpression.new(self)
          end

          def &(expression)
            AndExpression.new(self, expression)
          end

          def |(expression)
            OrExpression.new(self, expression)
          end
        end

        class NotExpression < Expression
          def initialize(expression)
            @expression = expression
          end

          def to_sql
            @expression.to_sql.not
          end
        end

        class AndExpression < Expression
          def initialize(left, right)
            @left = left
            @right = right
          end

          def to_sql
            @left.to_sql.and(@right.to_sql)
          end
        end

        class OrExpression < Expression
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
end