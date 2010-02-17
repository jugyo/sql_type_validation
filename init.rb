require 'sql_type_validation'
ActiveRecord::Base.send(:include, SqlTypeValidation)