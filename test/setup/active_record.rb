require 'active_record'
require 'escargot/adapter/active_record'
require 'yaml'
require 'logger'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/../database.yml'))

db_adapter = ENV['DB']

# no db passed, try one of these fine config-free DBs before bombing.
db_adapter ||=
  begin
    require 'rubygems'
    require 'sqlite'
    'sqlite'
  rescue MissingSourceFile
    begin
      require 'sqlite3'
      'sqlite3'
    rescue MissingSourceFile
    end
  end

if db_adapter.nil?
  raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
end

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/../active_record.log")
ActiveRecord::Base.establish_connection(config[db_adapter])

def TestModel(name, scope=nil, &block)
  klass = (scope || self).const_set(name, Class.new(ActiveRecord::Base))
  klass.class_eval &block
  klass.delete_all
  klass
end

ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.string :name
    t.string :country_code
    t.date :created_at
  end

  create_table :dogs, :force => true do |t|
    t.string :name
  end

  create_table :cats, :force => true do |t|
    t.string :name
  end

  create_table :legacy_users, :force => true, :primary_key => :legacy_id do |t|
    t.string :name
    t.string :country_code
    t.date :created_at
  end
end