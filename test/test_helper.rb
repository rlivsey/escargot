require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'

adapter = ENV['ADAPTER'] || "active_record"
require File.dirname(__FILE__) + "/setup/#{adapter}.rb"

$elastic_search_client = ElasticSearch.new("localhost:9200")

def resque_available
  begin
    require 'resque'
    require 'resque_unit'
    Resque.reset!
    return true
  rescue NameError, MissingSourceFile
    puts "Please install the 'resque' and 'resque_unit' gems to test the distributed mode."
    exit
  end
end

def flush_indexes_models
  Escargot.flush_all_indexed_models
end
