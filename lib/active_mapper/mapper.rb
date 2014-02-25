module ActiveMapper
  class Mapper
    attr_reader :mapped_class, :adapter

    def initialize(mapped_class, adapter)
      @mapped_class = mapped_class
      @adapter = adapter
    end

    def all?(&block)
      count == count(&block)
    end

    def any?(&block)
      select(&block).any?
    end

    def none?(&block)
      select(&block).none?
    end

    def one?(&block)
      select(&block).one?
    end

    def count(&block)
      select(&block).count
    end

    def min(attribute)
      find_all.min(attribute)
    end
    alias :min_by :min
    alias :minimum :min

    def max(attribute)
      find_all.max(attribute)
    end
    alias :max_by :max
    alias :maximum :max

    def minmax(attribute)
      find_all.minmax(attribute)
    end
    alias :minmax_by :minmax

    def avg(attribute)
      find_all.avg(attribute)
    end
    alias :average :avg

    def sum(attribute)
      find_all.sum(attribute)
    end

    def find(id = nil, &block)
      id ? first { |object| object.id == id } : first(&block)
    end

    def first(&block)
      select(&block).first
    end
    alias :detect :first

    def last(&block)
      select(&block).last
    end

    def select(&block)
      Relation.new(mapped_class, adapter, &block)
    end
    alias :find_all :select

    def reject(&block)
      select { |object| !block.call(object) }
    end

    def save(object)
      return false unless object.valid?

      if object.id
        adapter.update(mapped_class, object)
      else
        object.id = adapter.insert(mapped_class, object)
      end

      object
    end

    def delete(object)
      adapter.delete(mapped_class, object)
    end

    def delete_if(&block)
      adapter.delete_all(mapped_class, &block)
    end

    def keep_if(&block)
      delete_if { |object| !block.call(object) }
    end

    def clear
      adapter.delete_all(mapped_class)
    end
    alias :delete_all :clear
  end
end