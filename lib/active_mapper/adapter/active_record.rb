require 'active_record'
require 'active_mapper/adapter/active_record/query'
require 'active_mapper/adapter/active_record/order'

module ActiveMapper
  module Adapter
    class ActiveRecord
      def initialize
        @collection = {}
      end

      def find(klass, id)
        collection(klass).find_by(id: id)
      end

      def where(klass, options = {}, &block)
        active_record = collection(klass)
        query = Query.new(active_record.arel_table, &block)
        order = Order.new(&options[:order])

        records = active_record.where(query.to_sql)
        records = records.limit(options[:limit]) if options[:limit]
        records = records.offset(options[:offset]) if options[:offset]
        records = records.order(order.to_sql)

        records
      end

      def count(klass, &block)
        where(klass, &block).count
      end

      def minimum(klass, attribute, &block)
        calculate(:minimum, klass, attribute, &block)
      end

      def maximum(klass, attribute, &block)
        calculate(:maximum, klass, attribute, &block)
      end

      def average(klass, attribute, &block)
        calculate(:average, klass, attribute, &block)
      end

      def sum(klass, attribute, &block)
        calculate(:sum, klass, attribute, &block)
      end

      def insert(klass, object)
        active_record = collection(klass)
        attributes = serialize(klass, object)

        record = active_record.new(attributes)
        record.save
        record.id
      end

      def update(klass, object)
        find(klass, object.id).update_columns(serialize(klass, object))
      end

      def serialize(klass, object)
        collection(klass).column_names.dup.inject({}) do |memo, attribute|
          memo[attribute] = object.send(attribute)
          memo
        end
      end

      def unserialize(klass, object)
        klass.new(serialize(klass, object))
      end

      def delete(klass, object)
        find(klass, object.id).delete
      end

      def delete_all(klass, &block)
        where(klass, &block).delete_all
      end

      private

      def collection(klass)
        @collection[klass] ||= begin
          active_record = Class.new(::ActiveRecord::Base)
          active_record.table_name = klass.model_name.plural
          active_record
        end
      end

      def calculate(operation, klass, attribute, &block)
        where(klass, &block).send(operation, attribute)
      end
    end
  end
end