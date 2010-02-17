ActiveRecord::Schema.define(:version => 0) do
  create_table :blogs, :force => true do |t|
    t.column :id, :integer
  end

  create_table :categories, :force => true do |t|
    t.column :id,   :integer
    t.column :name, :string, :null => false
    t.column :foo,  :string, :null => false
  end

  create_table :entries, :force => true do |t|
    t.column :id,                         :integer
    t.column :blog_id,                    :integer, :null => false
    t.column :category_id,                :integer
    t.column :foo,                        :string, :limit => 10
    t.column :allow_null_string,          :string
    t.column :not_null_string,            :string, :null => false
    t.column :limit_10_string,            :string, :limit => 10
    t.column :not_null_limit_10_string,   :string, :limit => 10, :null => false
    t.column :allow_null_integer,         :integer
    t.column :not_null_integer,           :integer, :null => false
    t.column :limit_10_integer,           :integer, :limit => 10
    t.column :not_null_limit_10_integer,  :integer, :limit => 10, :null => false
    t.column :allow_null_boolean,         :boolean
    t.column :not_null_boolean,           :boolean, :null => false
    t.column :limit_100_text,             :text, :limit => 100
  end
end
