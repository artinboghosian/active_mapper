require 'active_mapper/adapter/arel/relation'

module ActiveMapper
  module Adapter
    class Arel
      def initialize
        @tables = {}
      end

      def find(klass, id)
        Relation.new(table(klass)).where { |object| object.id == id }.first
      end

      def where(klass, options = {}, &block)
        Relation.new(table(klass)).where(&block)
      end

      def count(klass, &block)
        where(klass, &block).count
      end

      def maximum(klass, attribute, &block)
        where(klass, &block).maximum(attribute)
      end

      def minimum(klass, attribute, &block)
        where(klass, &block).minimum(attribute)
      end

      def sum(klass, attribute, &block)
        where(klass, &block).sum(attribute)
      end

      def average(klass, attribute, &block)
        where(klass, &block).average(attribute)
      end

      def insert(klass, object)
        attributes = serialize(klass, object).reverse_merge(
          created_at: Time.now,
          updated_at: Time.now
        )

        Relation.new(table(klass)).insert(attributes.except(:id))
      end

      def update(klass, object)
        relation = where(klass) { |record| record.id == object.id }
        attributes = serialize(klass, object).merge(updated_at: Time.now)

        relation.update(attributes.except(:id))
      end

      def delete(klass, object)
        delete_all(klass) { |record| record.id == object.id }
      end

      def delete_all(klass, &block)
        where(klass, &block).delete
      end

      def serialize(klass, object)
        table(klass).columns.inject({}) do |memo, column|
          memo[column.name] = object.send(column.name)
          memo
        end.with_indifferent_access
      end

      def unserialize(klass, attributes)
        klass.new(attributes.with_indifferent_access.slice(*table(klass).columns.map(&:name)))
      end

      private

      def table(klass)
        @tables[klass] ||= Table.new(klass.model_name.plural)
      end

      class Table < SimpleDelegator
        def initialize(name)
          super(::Arel::Table.new(name))
        end

        def columns
          @columns ||= __getobj__.send(:attributes_for, engine.connection.columns(name))
        end
      end
    end
  end
end