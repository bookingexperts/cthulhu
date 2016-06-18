module Cthulhu
  class Scopper < Struct.new(:root, :klass, :chained_classes, :chain, :inverse_chain, :has_and_belongs_to_many_usages, :nullify)

    def scope
      @scope ||= begin
        result = klass.unscoped
        left = []
        right = []
        @last_klass = klass
        @last_inverse_klass = root.class
        chain.each_with_index do |link, index|
          reflection = @last_klass.reflections[link]
          inverse_reflection = @last_inverse_klass.reflections[inverse_chain[index]]
          left << reflection
          right.unshift inverse_reflection
          @last_klass = chained_classes[index + 1]
          @last_inverse_klass = inverse_reflection.klass
        end
        left.each_with_index do |_, index|
          result = result.joins join_expression(left[index], right[index], index)
        end
        last_table = left.length > 0 ? table_alias(left.length - 1) : root.class.table_name
        result.reorder('').where last_table => { id: root.id }
      end
    end

    def delete!
      has_and_belongs_to_many_usages.each do |reflection_name|
        reflection = scope.reflections[reflection_name]
        table = t reflection.join_table
        root.class.connection.
          execute "delete from #{table} where #{table}.#{reflection.foreign_key} in (#{scope.select(:id).to_sql})"
      end
      nullify.each do |name, args|
        Scopper.new(root, *args, [], {}).nullify! klass.reflections[name].foreign_key
      end
      scope.delete_all
    end

    def nullify! column
      scope.update_all column => nil
    end

  private

    def join_expression reflection, inverse_reflection, index
      previous_table = t(index.zero? ? inverse_reflection.table_name : "t#{index - 1}")
      current_table = t table_alias(index)
      current_class = chained_classes[index + 1]
      association_primary_key = reflection.association_primary_key rescue current_class.primary_key
      [
        "inner join #{current_class.quoted_table_name} as #{current_table} on ",
        [
          [
            "#{current_table}.#{c(association_primary_key)}",
            "#{previous_table}.#{c(reflection.foreign_key)}"
          ].join('='),
          (
            if reflection.polymorphic?
              types = ([current_class] + current_class.subclasses).map { |type| q type }
              [
                "#{previous_table}.#{c(reflection.foreign_type)} in (#{types.join(',')})"
              ]
            end
          )
        ].compact.join(' AND ')
      ].join
    end

    def table_alias index
      "t#{index}"
    end

    def c column
      klass.connection.quote_column_name column
    end

    def q text
      klass.connection.quote text
    end

    def t table
      klass.connection.quote_table_name table
    end

  end
end
