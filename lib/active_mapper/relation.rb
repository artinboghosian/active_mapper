require 'delegate'

module ActiveMapper
  class Relation
    extend Forwardable

    def_delegators :to_a, :each, :map

    def initialize(mapped_class, adapter, &block)
      @mapped_class = mapped_class
      @adapter = adapter
      @block = block
    end

    def initialize_copy(other)
      super
      @to_a = nil
    end

    def any?
      count > 0
    end

    def none?
      !any?
    end
    alias :empty? :none?

    def one?
      count == 1
    end

    def count
      @count ||= @adapter.count(@mapped_class, &@block)
    end
    alias :length :count
    alias :size :count

    def min(attribute)
      @min ||= @adapter.minimum(@mapped_class, attribute, &@block)
    end
    alias :minimum :min

    def max(attribute)
      @max ||= @adapter.maximum(@mapped_class, attribute, &@block)
    end
    alias :maximum :max

    def minmax(attribute)
      [min(attribute), max(attribute)]
    end

    def avg(attribute)
      @avg ||= @adapter.average(@mapped_class, attribute, &@block)
    end
    alias :average :avg

    def sum(attribute)
      @sum ||= @adapter.sum(@mapped_class, attribute, &@block)
    end

    def drop(number)
      @offset = number
      dup
    end

    def take(number)
      @limit = number
      dup
    end

    def first(number = 1)
      objects = drop(0).take(number).to_a

      if number == 1
        objects.first
      else
        objects
      end
    end

    def last(number = 1)
      objects = drop(0).take(number).reverse.to_a

      if number == 1
        objects.first
      else
        objects
      end
    end

    def sort(attribute)
      @attribute = attribute
      @direction = :asc
      dup
    end
    alias :sort_by :sort

    def reverse
      @direction = @direction && @direction == :desc ? :asc : :desc
      dup
    end

    def to_a
      @to_a||= @adapter.where(@mapped_class, options, &@block).map { |record| @adapter.unserialize(@mapped_class, record) }
    end

    private

    def options
      { offset: @offset, limit: @limit, order: order }
    end

    def order
      [@attribute || :id, @direction || :asc] if @attribute || @direction
    end
  end
end