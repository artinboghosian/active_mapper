require 'delegate'
require 'active_mapper/relation/sort'

module ActiveMapper
  class Relation
    extend Forwardable

    def_delegators :to_a, :each, :map

    def initialize(mapped_class, adapter, &block)
      @mapped_class = mapped_class
      @adapter = adapter
      @block = block
      @sort = Sort.new
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

    def sort_by(&block)
      @sort.call(&block)
      dup
    end
    alias :sort :sort_by

    def reverse
      @sort.reverse
      dup
    end

    def to_a
      @to_a||= @adapter.where(@mapped_class, options, &@block).map { |record| @adapter.unserialize(@mapped_class, record) }
    end

    private

    def options
      { offset: @offset, limit: @limit, order: @sort.to_a }
    end
  end
end