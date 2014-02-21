module ActiveMapper
  module Adapter
    class ActiveRecord
      class QueryAttribute
        def initialize(attribute)
          @attribute = attribute
        end

        def in(*collection)
          QueryExpression.new(@attribute, :in, collection)
        end

        def ==(value)
          QueryExpression.new(@attribute, :eq, value)
        end

        def !=(value)
          QueryExpression.new(@attribute, :not_eq, value)
        end

        def >(value)
          QueryExpression.new(@attribute, :gt, value)
        end

        def >=(value)
          QueryExpression.new(@attribute, :gteq, value)
        end

        def <(value)
          QueryExpression.new(@attribute, :lt, value)
        end

        def <=(value)
          QueryExpression.new(@attribute, :lteq, value)
        end
      end
    end
  end
end