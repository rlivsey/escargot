require 'test_helper'
# tests the behaviour of Searching multiple models

class SearchMultipleModels < Test::Unit::TestCase

    flush_indexes_models

  TestModel("User") do
    elastic_index
  end

  TestModel("Dog") do
    elastic_index
  end

  TestModel("Cat") do
    elastic_index
  end

  def setup

    Escargot.flush_all_indexed_models

    User.new(:name => 'Cote').save!
    User.new(:name => 'Grillo').save!
    User.new(:name => 'Mencho').save!

    Dog.new(:name => 'Cote').save!
    Dog.new(:name => 'Cote').save!
    Dog.new(:name => 'Grillo').save!

    Cat.new(:name => 'Cote').save!
    Cat.new(:name => 'Cote').save!
    Cat.new(:name => 'Mencho').save!

    User.refresh_index
    Dog.refresh_index
    Cat.refresh_index

  end


  def teardown
    User.delete_all
    User.delete_index
    Dog.delete_all
    Dog.delete_index
    Cat.delete_all
    Cat.delete_index
    Escargot.flush_all_indexed_models
  end


  def test_search_multiple_models

    # Search "Cote" in all Models
    assert_equal Escargot.search("Cote").total_entries, 5

    # Search "Cote" in model User
    assert_equal Escargot.search("Cote", :classes =>[User]).total_entries, 1

    # Search "Cote" in model User, if it's only one model you don't need pass like array
    assert_equal Escargot.search("Cote", :classes => User).total_entries, 1

    # Search "Cote" in model Dog
    assert_equal Escargot.search("Cote", :classes =>[Dog]).total_entries, 2

    # Search "Cote" in model User, Dog
    assert_equal Escargot.search("Cote", :classes =>[User,Dog]).total_entries, 3
  end
end
