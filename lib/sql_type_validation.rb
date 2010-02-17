require 'validation_reflection'

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

    def define_sql_type_validation(column)
      return if column.primary

      validations_to_define = []

      case column.type
      when :string, :text
        unless column.null
          validations_to_define << {:method => :validates_presence_of, :options => [column.name]}
        end
        validations_to_define << {
          :method => :validates_length_of,
          :options => [column.name, {:maximum => column.limit, :allow_nil => column.null}]
        }
      when :integer
        association = reflect_on_all_associations.detect { |i|
          i.association_foreign_key == column.name
        }
        if association
          unless column.null
            validations_to_define << {:method => :validates_presence_of, :options => [association.name]}
          end
        else
          unless column.null
            validations_to_define << {:method => :validates_presence_of, :options => [column.name]}
          end
          if column.limit
            validations_to_define << {
              :method => :validates_numericality_of,
              :options => [column.name, {:less_than => 10**column.limit, :allow_nil => column.null}]
            }
          end
        end
      when :boolean
        unless column.null
          validations_to_define << {
            :method => :validates_inclusion_of, :options => [column.name, {:in => [true, false]}]
          }
        end
      end

      validations_to_define.each do |validation|
        unless reflect_on_validations_for(column.name).any? { |v| v.macro == validation[:method] }
          self.send(validation[:method], *validation[:options])
        end
      end
    end
  end
end
