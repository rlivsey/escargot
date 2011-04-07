require 'escargot/adapter/mongo_mapper'

MongoMapper.database = 'escargot-test'

def TestModel(name, scope=nil, &block)
  klass = (scope || self).const_set(name, Class.new)
  klass.class_eval do
    include MongoMapper::Document
  end
  klass.class_eval &block

  # all other models just have 'name' field which is picked up a String automatically
  # but we need to specifically define the created_at so it gets cast to a Time
  # TODO - nicer way of setting up models/schemas on a per adapter basis - ModelFactory?!
  if name == "User"
    klass.class_eval do
      key :created_at, Time
    end
  end

  klass.delete_all
  klass
end
