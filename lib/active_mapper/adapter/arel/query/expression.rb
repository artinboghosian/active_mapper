module ActiveMapper
  module Adapter
    class Arel
      class Query
        class Expression
          def initialize(expression)
            @expression = expression
          end

          def call
            @expression
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
          def call
            super.call.not
          end
        end

        class AndExpression < Expression
          def initialize(left, right)
            super(left.call.and(right.call))
          end
        end

        class OrExpression < Expression
          def initialize(left, right)
            super(left.call.or(right.call))
          end
        end
      end
    end
  end
end