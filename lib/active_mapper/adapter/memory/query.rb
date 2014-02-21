module ActiveMapper
  module Adapter
    class Memory
      class Query
        def initialize(&block)
          @block = block
        end

        def to_proc
          @block ? @block.call(self).to_proc : proc { true }
        end

        def method_missing(name, *args, &block)
          QueryAttribute.new(name)
        end
      end
    end
  end
end