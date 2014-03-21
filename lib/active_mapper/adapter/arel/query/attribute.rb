module ActiveMapper
  module Adapter
    class Arel
      class Query
        class Attribute
          def initialize(attribute)
            @attribute = attribute
          end

          def in(*collection)
            Expression.new(@attribute.in(*collection))
          end

          def not_in(*collection)
            Expression.new(@attribute.not_in(*collection))
          end

          def starts_with(value)
            Expression.new(@attribute.matches("#{value}%"))
          end

          def contains(value)
            Expression.new(@attribute.matches("%#{value}%"))
          end

          def ends_with(value)
            Expression.new(@attribute.matches("%#{value}"))
          end

          def ==(value)
            Expression.new(@attribute.eq(value))
          end

          def !=(value)
            Expression.new(@attribute.not_eq(value))
          end

          def >(value)
            Expression.new(@attribute.gt(value))
          end

          def >=(value)
            Expression.new(@attribute.gteq(value))
          end

          def <(value)
            Expression.new(@attribute.lt(value))
          end

          def <=(value)
            Expression.new(@attribute.lteq(value))
          end
        end
      end
    end
  end
end