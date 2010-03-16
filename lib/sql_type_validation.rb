module SqlTypeValidation
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods
    def sql_type_validation(*columns)
      columns.flatten.each do |column|
        case column
        when String, Symbol
          column = self.columns_hash[column.to_s]
          raise "column not found: #{column}" unless column
        when ActiveRecord::ConnectionAdapters::Column
          column = column
        else
          raise "unknown column type: #{column.inspect}"
        end

        define_sql_type_validation(column)
      end
    end

    def tokenizer
      if defined? TOKENIZER
        TOKENIZER
      else
        lambda {|str| str.bytes.to_a }
      end
    end

    def define_sql_type_validation(column)
      return if column.primary

      case column.type
      when :string, :text
        unless column.null
          validates_presence_of column.name
        end
        validates_length_of column.name,
          :maximum   => column.limit,
          :allow_blank => true,
          :tokenizer => tokenizer
      when :integer
        association = reflect_on_all_associations.detect { |i|
          i.association_foreign_key == column.name
        }
        if association
          unless column.null
            validates_presence_of association.name
          end
        else
          unless column.null
            validates_presence_of column.name
          end
          if column.limit
            validates_numericality_of column.name,
              :less_than => 10**column.limit,
              :allow_blank => true
          end
        end
      when :boolean
        unless column.null
          validates_inclusion_of column.name, :in => [true, false]
        end
      end
    end
  end
end
