require 'active_mapper/adapter/arel/query'
require 'active_mapper/adapter/arel/order'

module ActiveMapper
  module Adapter
    class Arel
      class Relation
        attr_reader :table

        def initialize(table)
          @table = table
        end

        def manager
          @manager ||= table.project(::Arel.star)
        end

        def all
          @all ||= execute(manager.to_sql)
        end

        def map(&block)
          all.map(&block)
        end

        def first
          all.first
        end

        def count
          calculate(:count, :id)
        end

        def maximum(attribute)
          calculate(:maximum, attribute)
        end

        def minimum(attribute)
          calculate(:minimum, attribute)
        end

        def sum(attribute)
          calculate(:sum, attribute)
        end

        def average(attribute)
          calculate(:average, attribute)
        end

        def where(&block)
          manager.where(Query.new(table, block).call) if block_given?
          self
        end

        def order(&block)
          manager.order(Order.new(table, block).call) if block_given?
          self
        end

        def offset(number)
          manager.skip(number) if number
          self
        end

        def limit(number)
          manager.take(number) if number
          self
        end

        def insert(attributes)
          values = extract_values(attributes)
          im = table.compile_insert(values)

          table.engine.connection.insert(im.to_sql)
        end

        def update(attributes)
          values = extract_values(attributes)
          um = manager.compile_update(values)

          execute(um.to_sql)
        end

        def delete
          execute(manager.compile_delete.to_sql)
        end

        private

        def extract_values(attributes)
          attributes.map { |name, value| [table[name], value] }
        end

        def execute(sql)
          result = nil

          milliseconds = Benchmark.ms do
            result = table.engine.connection.execute(sql)
          end

          puts "SQL (#{milliseconds.round(2)}ms) - #{sql}"

          result
        end

        def calculate(operator, attribute)
          manager.projections = []
          manager.project(table[attribute].send(operator))

          execute(manager.to_sql).first[0]
        end
      end
    end
  end
end