module ActiveMapper
  module Adapter
    class Memory
      class Expression
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
          NotExpression.new(self)
        end

        def &(expression)
          AndExpression.new(self, expression)
        end

        def |(expression)
          OrExpression.new(self, expression)
        end
      end

      class InvertedExpression < Expression
        def initialize(value, comparator, attribute)
          super(attribute, comparator, value)
        end

        def to_proc
          proc do |object|
            @value.send(@comparator, object.send(@attribute))
          end
        end
      end

      class NotExpression < Expression
        def initialize(expression)
          @expression = expression
        end

        def to_proc
          proc do |object|
            !@expression.to_proc.call(object)
          end
        end
      end

      class AndExpression < Expression
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

      class OrExpression < Expression
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