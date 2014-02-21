module ActiveMapper
  module Adapter
    class Memory
      class QueryExpression
        def initialize(attribute, comparator, value)
          @attribute = attribute
          @comparator = comparator
          @value = value
        end

        def to_proc
          proc do |object|
            object.send(@attribute).send(@comparator, @value)
          end
        end

        def &(expression)
          CompositeQueryExpression.new(self, :&, expression)
        end

        def |(expression)
          CompositeQueryExpression.new(self, :|, expression)
        end
      end

      class InvertedQueryExpression < QueryExpression
        def initialize(value, comparator, attribute)
          super(attribute, comparator, value)
        end

        def to_proc
          proc do |object|
            @value.send(@comparator, object.send(@attribute))
          end
        end
      end

      class NegatedQueryExpression < QueryExpression
        def initialize(expression)
          @expression = expression
        end

        def to_proc
          proc do |object|
            !@expression.to_proc.call(object)
          end
        end
      end

      class CompositeQueryExpression < QueryExpression
        def initialize(left, comparator, right)
          @left = left
          @comparator = comparator
          @right = right
        end

        def to_proc
          proc do |object|
            @left.to_proc.call(object).send(@comparator, @right.to_proc.call(object))
          end
        end
      end
    end
  end
end