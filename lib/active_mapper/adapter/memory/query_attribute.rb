module ActiveMapper
  module Adapter
    class Memory
      class QueryAttribute
        def initialize(attribute)
          @attribute = attribute
        end

        def in(*collection)
          InvertedQueryExpression.new(collection, :include?, @attribute)
        end

        def not_in(*collection)
          !(self.in(*collection))
        end

        def starts_with(value)
          matches(/^#{value}/i)
        end

        def contains(value)
          matches(/#{value}/i)
        end

        def ends_with(value)
          matches(/#{value}$/i)
        end

        def ==(value)
          QueryExpression.new(@attribute, :==, value)
        end

        def !=(value)
          QueryExpression.new(@attribute, :!=, value)
        end

        def >(value)
          QueryExpression.new(@attribute, :>, value)
        end

        def >=(value)
          QueryExpression.new(@attribute, :>=, value)
        end

        def <(value)
          QueryExpression.new(@attribute, :<, value)
        end

        def <=(value)
          QueryExpression.new(@attribute, :<=, value)
        end

        private

        def matches(regexp)
          QueryExpression.new(@attribute, :match, regexp)
        end
      end
    end
  end
end