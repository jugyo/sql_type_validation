SqlTypeValidation
=================

SqlTypeValidation provides validations by sql type of actual columns.

Usage
-----

    class Category < ActiveRecord::Base
      sql_type_validation :name
    end

    class Entry < ActiveRecord::Base
      sql_type_validation columns
    end

Copyright (c) 2010 jugyo, released under the MIT license
