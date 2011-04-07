require 'test_helper'

class ElasticIndexTest < Test::Unit::TestCase
  
  TestModel("User") do
    elastic_index
  end

  def test_index_name
    assert_equal User.index_name, 'elastic_index_test-user'
  end
  
  def test_search_method_present
    assert User.respond_to?(:search)
  end
  
  def test_registered_as_indexed_model
    Escargot.indexed_models.include?(User)
  end
  
end