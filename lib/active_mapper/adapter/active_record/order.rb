module ActiveMapper
  module Adapter
    class ActiveRecord
      class Order
        def initialize(&block)
          @block = block
        end

        def to_sql
          attributes.inject({}) do |memo, attribute|
            memo = memo.merge(attribute.to_sql)
            memo
          end
        end

        def method_missing(name, *args, &block)
          Attribute.new(name)
        end

        private

        def attributes
          @block ? [@block.call(self)].flatten : []
        end

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