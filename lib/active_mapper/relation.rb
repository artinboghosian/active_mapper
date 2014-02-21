module ActiveMapper
  class Relation
    def initialize(mapped_class, adapter, &block)
      @mapped_class = mapped_class
      @adapter = adapter
      @block = block
    end

    def initialize_copy(other)
      super
      @all = nil
    end

    def all
      @all ||= @adapter.where(@mapped_class, options, &@block).map { |record| @adapter.unserialize(@mapped_class, record) }
    end

    def first
      page(1).per_page(1).all.first
    end

    def last
      page(1).per_page(1).reverse_order.first
    end

    def count
      @count ||= @adapter.count(@mapped_class, &@block)
    end

    def page(number)
      @page = number
      dup
    end

    def per_page(number)
      @limit = number
      dup
    end

    def order_by(attribute)
      @attribute = attribute
      dup
    end

    def reverse_order
      @direction = @direction && @direction == :desc ? :asc : :desc
      dup
    end

    private

    def options
      { offset: offset, limit: @limit, order: order }
    end

    def offset
      (@page - 1) * @limit if @page && @limit
    end

    def order
      return unless @attribute || @direction

      attribute = @attribute || :id
      direction = @direction || :asc

      [attribute, direction]
    end
  end
end