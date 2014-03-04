module ActiveMapper
  module Adapter
    class Memory
      class Order
        def initialize(&block)
          @block = block
        end

        def to_proc
          proc do |x,y|
            attributes.sum do |attribute|
              attribute.to_proc.call(x,y)
            end
          end
        end

        def method_missing(name, *args, &block)
          Attribute.new(name)
        end

        private

        def attributes
          @block ? [@block.call(self)].flatten : [Attribute.new(:id)]
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