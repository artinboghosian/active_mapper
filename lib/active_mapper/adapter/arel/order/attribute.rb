module ActiveMapper
  module Adapter
    class Arel
      class Order
        class Attribute
          def initialize(attribute)
            @attribute = attribute
          end

          def call
            @attribute
          end

          def -@
            @attribute = @attribute.reverse
            self
          end
          alias :reverse :-@
        end
      end
    end
  end
end