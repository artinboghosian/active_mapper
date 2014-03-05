module ActiveMapper
  module Adapter
    class ActiveRecord
      class Order
        class Attribute
          def initialize(name)
            @name = name
            @direction = :asc
          end

          def -@
            @direction = asc? ? :desc : :asc
            self
          end

          def to_sql
            { @name => @direction }
          end

          private

          def asc?
            @direction == :asc
          end
        end
      end
    end
  end
end