module ActiveMapper
  class Relation
    class Sort
      def initialize
        @default = [Attribute.new(:id)]
        @attributes = []
      end

      def call(&block)
        yield(self)
      end

      def to_a
        if @attributes.empty?
          @default.map(&:to_a)
        else
          @attributes.map(&:to_a)
        end
      end

      def reverse
        @default.map(&:reverse)
        @attributes.map(&:reverse)
      end

      def method_missing(name, *args, &block)
        @attributes << Attribute.new(name)
        @attributes.last
      end

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
          @direction = @direction == :asc ? :desc : :asc
        end

        def to_a
          [@name, @direction]
        end
      end
    end
  end
end