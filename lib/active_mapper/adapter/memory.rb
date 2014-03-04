require 'active_mapper/adapter/memory/query'
require 'active_mapper/adapter/memory/order'

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
        query = Query.new(&block)
        order = Order.new(&options[:order])

        records = collection(klass).values.select(&query.to_proc)
        records = records.sort(&order.to_proc)
        records = records.drop(options[:offset]) if options[:offset]
        records = records.take(options[:limit]) if options[:limit]

        records
      end

      def count(klass, &block)
        where(klass, &block).count
      end

      def minimum(klass, attribute, &block)
        where(klass, order: proc { |object| object.send(attribute) }, &block).first.send(attribute)
      end

      def maximum(klass, attribute, &block)
        where(klass, order: proc { |object| -object.send(attribute) }, &block).first.send(attribute)
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