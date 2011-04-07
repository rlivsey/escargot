# coding: utf-8
require 'test_helper'

class AlternatePrimaryKeyTest < Test::Unit::TestCase

  resque_available

  TestModel("LegacyUser") do
    set_primary_key :legacy_id
    elastic_index :updates => false
  end

  # minimal test to ensure that models with a non-default primary key work
  def test_legacy_model
    LegacyUser.delete_all
    LegacyUser.delete_index

    LegacyUser.new(:name => 'John the Long').save!
    LegacyUser.new(:name => 'Peter the Young').save!
    LegacyUser.new(:name => 'Peter the Old').save!
    LegacyUser.new(:name => 'Bob the Skinny').save!
    LegacyUser.new(:name => 'Jamie the Flying Machine').save!

    Escargot::DistributedIndexing.create_index_for_model(LegacyUser)
    Resque.run!
    LegacyUser.refresh_index

    results = LegacyUser.search("peter")
    assert_equal results.total_entries, 2
  end

  def teardown
    LegacyUser.delete_all
    LegacyUser.delete_index
  end
end
