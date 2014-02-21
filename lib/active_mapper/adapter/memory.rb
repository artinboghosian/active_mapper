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
        attribute, direction = options[:order] || [:id, :asc]

        records = collection(klass).values.select(&block)
        records = if direction == :desc
          records.sort { |x,y| [y.send(attribute), x.id] <=> [x.send(attribute), x.id] }
        else
          records.sort { |x,y| [x.send(attribute), x.id] <=> [y.send(attribute), x.id] }
        end

        records = records.drop(options[:offset]) if options[:offset]
        records = records.take(options[:limit]) if options[:limit]

        records
      end

      def count(klass, &block)
        where(klass, &block).count
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