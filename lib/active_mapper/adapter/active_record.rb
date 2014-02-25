require 'active_record'
require 'active_mapper/adapter/active_record/query'

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
        attribute, direction = options[:order]
        active_record = collection(klass)
        query = Query.new(active_record.arel_table, &block)

        records = active_record.where(query.to_sql)
        records = records.limit(options[:limit]) if options[:limit]
        records = records.offset(options[:offset]) if options[:offset]
        records = records.order(attribute) if attribute
        records = records.reverse_order if direction == :desc

        records
      end

      def count(klass, &block)
        where(klass, &block).count
      end

      def min(klass, attribute, &block)
        where(klass, &block).minimum(attribute)
      end

      def max(klass, attribute, &block)
        where(klass, &block).maximum(attribute)
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
        attributes = collection(klass).column_names.dup
        attributes.inject({}) do |memo, attribute|
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
    end
  end
end