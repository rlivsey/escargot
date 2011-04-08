require 'test_helper'

class ElasticIndexTest < Test::Unit::TestCase

  TestModel("User") do
    elastic_index
  end

  TestModel("LegacyUser") do
    elastic_index :index_name => "old_users", :index_type => "old_user"
  end

  TestModel("Animal") do
    elastic_index
  end
  
  # STI
  TestModel("Dog", nil, Animal) do
  end

  def test_index_name
    assert_equal User.index_name, 'elastic_index_test-user'
    assert_equal Dog.index_name, 'elastic_index_test-animal'
    assert_equal LegacyUser.index_name, 'old_users'
  end

  def test_index_type
    assert_equal User.index_type, 'elastic_index_test-user'
    assert_equal Dog.index_type, 'elastic_index_test-animal'
    assert_equal LegacyUser.index_type, 'old_user'
  end

  def test_search_method_present
    assert User.respond_to?(:search)
  end

  def test_registered_as_indexed_model
    Escargot.indexed_models.include?(User)
  end

end