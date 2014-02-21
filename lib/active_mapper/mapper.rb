module ActiveMapper
  class Mapper
    attr_reader :mapped_class, :adapter

    def initialize(mapped_class, adapter)
      @mapped_class = mapped_class
      @adapter = adapter
    end

    def find(id)
      first { |object| object.id == id }
    end

    def all(&block)
      where(&block).all
    end

    def first(&block)
      where(&block).first
    end

    def last(&block)
      where(&block).last
    end

    def count(&block)
      where(&block).count
    end

    def where(&block)
      Relation.new(mapped_class, adapter, &block)
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

    def delete_all(&block)
      adapter.delete_all(mapped_class, &block)
    end

    def ==(other)
      other.mapped_class == mapped_class
    end
  end
end