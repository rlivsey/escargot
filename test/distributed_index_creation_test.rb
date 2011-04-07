# coding: utf-8
require 'test_helper'

# tests the behaviour of the index creation tasks that run in the distributed mode
# without real time support

class DistributedIndexCreation < Test::Unit::TestCase

  resque_available

  TestModel("User") do
    elastic_index :updates => false
  end

  def test_distributed_indexing
    User.delete_all
    User.delete_index

    User.new(:name => 'John the Long').save!
    User.new(:name => 'Peter the Young').save!
    User.new(:name => 'Peter the Old').save!
    User.new(:name => 'Bob the Skinny').save!
    User.new(:name => 'Jamie the Flying Machine').save!

    Escargot::DistributedIndexing.create_index_for_model(User)
    Resque.run!
    User.refresh_index

    results = User.search("peter")

    assert_equal results.total_entries, 2
    assert_equal [results.first.name, results.second.name].sort, ['Peter the Old', 'Peter the Young']

    results = User.search("LONG or SKINNY")
    assert_equal results.total_entries, 2

    results = User.search("*")
    assert_equal results.total_entries, 5
  end

  def test_index_rotation
    # create a first version of the index
    User.delete_all
    User.delete_index

    User.create(:name => 'John the Long')
    User.create(:name => 'Peter the Fat')
    User.create(:name => 'Bob the Skinny')
    User.create(:name => 'Jamie the Flying Machine')

    Escargot::DistributedIndexing.create_index_for_model(User)
    Resque.run!

    # create a second version of the index

    User.first.destroy
    User.first.destroy

    Escargot::DistributedIndexing.create_index_for_model(User)
    Resque.run!
    User.refresh_index

    # check that there are no traces of the older index
    assert_equal User.search_count, 2
  end

  def teardown
    User.delete_all
    User.delete_index
  end
end
