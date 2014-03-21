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

        class Query
          def initialize(table, block)
            @table = table
            @block = block
          end

          def call
            @block.call(self).call
          end

          def method_missing(name, *args, &block)
            Attribute.new(@table[name])
          end
          class Attribute
            def initialize(attribute)
              @attribute = attribute
            end

            def ==(value)
              Expression.new(@attribute.eq(value))
            end

            def >(value)
              Expression.new(@attribute.gt(value))
            end

            def <(value)
              Expression.new(@attribute.lt(value))
            end
          end

          class Expression
            def initialize(expression)
              @expression = expression
            end

            def call
              @expression
            end

            def !
              NotExpression.new(self)
            end

            def &(expression)
              AndExpression.new(self, expression)
            end

            def |(expression)
              OrExpression.new(self, expression)
            end
          end

          class NotExpression < Expression
            def call
              super.not
            end
          end

          class AndExpression < Expression
            def initialize(left, right)
              super(left.call.and(right.call))
            end
          end

          class OrExpression < Expression
            def initialize(left, right)
              super(left.call.or(right.call))
            end
          end
        end
      end
    end
  end
end