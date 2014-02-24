module ActiveMapper
  class Mapper
    attr_reader :mapped_class, :adapter

    def initialize(mapped_class, adapter)
      @mapped_class = mapped_class
      @adapter = adapter
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

    def find(&block)
      select(&block).first
    end
    alias :detect :find
    alias :first :find

    def find_all(&block)
      select(&block).to_a
    end

    def find_by_id(id)
      find { |object| object.id == id }
    end

    def last(&block)
      select(&block).last
    end

    def select(&block)
      Relation.new(mapped_class, adapter, &block)
    end

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

    def clear
      adapter.delete_all(mapped_class)
    end
    alias :delete_all :clear

    def keep_if(&block)
      delete_if { |object| !block.call(object) }
    end

    def ==(other)
      other.mapped_class == mapped_class
    end
  end
end