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

      class NotQueryExpression < QueryExpression
        def initialize(expression)
          @expression = expression
        end

        def to_proc
          proc do |object|
            !@expression.to_proc.call(object)
          end
        end
      end

      class AndQueryExpression < QueryExpression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def to_proc
          proc do |object|
            @left.to_proc.call(object) && @right.to_proc.call(object)
          end
        end
      end

      class OrQueryExpression < QueryExpression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def to_proc
          proc do |object|
            @left.to_proc.call(object) || @right.to_proc.call(object)
          end
        end
      end
    end
  end
end