module ActiveMapper
  module Adapter
    class Memory
      class Order
        class Attribute
          def initialize(name)
            @name = name
            @direction = :asc
          end

          def -@
            @direction = :desc
            self
          end

          def reverse
            @direction = asc? ? :desc : :asc
            self
          end

          def to_proc
            proc do |x,y|
              if asc?
                x.send(@name) <=> y.send(@name)
              else
                y.send(@name) <=> x.send(@name)
              end
            end
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