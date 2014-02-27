require 'active_mapper/adapter/memory/query'

module ActiveMapper
  module Adapter
    class Memory
      def initialize
        @collection = {}
      end

      def find(klass, id)
        collection(klass)[id]
      end

      def where(klass, options = {}, &block)
        options[:order] ||= [[:id, :asc]]
        query = Query.new(&block)

        # proc do |x,y|
        #   [x.name, y.age] <=> [y.name, x.age]
        # end
        order = proc do |x,y|
          left = []
          right = []

          options[:order].each do |data|
            attribute, direction = data

            if direction == :desc
              left << y.send(attribute)
              right << x.send(attribute)
            else
              left << x.send(attribute)
              right << y.send(attribute)
            end
          end

          left <=> right
        end

        records = collection(klass).values.select(&query.to_proc)
        records = records.sort(&order)
        records = records.drop(options[:offset]) if options[:offset]
        records = records.take(options[:limit]) if options[:limit]

        records
      end

      def count(klass, &block)
        where(klass, &block).count
      end

      def minimum(klass, attribute, &block)
        where(klass, order: [[attribute, :asc]], &block).first.send(attribute)
      end

      def maximum(klass, attribute, &block)
        where(klass, order: [[attribute, :desc]], &block).first.send(attribute)
      end

      def average(klass, attribute, &block)
        sum(klass, attribute, &block).to_f / count(klass, &block)
      end

      def sum(klass, attribute, &block)
        where(klass, &block).sum(&:"#{attribute}")
      end

      def insert(klass, object)
        object = object.dup
        object.id = (collection(klass).keys.last || 0) + 1

        collection(klass)[object.id] = object
        object.id
      end

      def update(klass, object)
        collection(klass)[object.id] = object.dup
      end

      def delete(klass, object)
        collection(klass).delete(object.id)
      end

      def delete_all(klass, &block)
        where(klass, &block).each do |object|
          delete(klass, object)
        end
      end
      
      def unserialize(klass, object)
        object
      end

      private

      def collection(klass)
        @collection[klass] ||= {}
      end
    end
  end
end